//
//  TransactionListViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 27/03/2026.
//

import Foundation
import Toasty

/// Manages the list of transactions and handles delete operations.
@MainActor
@Observable
final class TransactionListViewModel {

    var showAddTransaction = false
    var transactions: [Transaction] = []
    var accountNames: [UUID: String] = [:]
    var institutionNames: [UUID: String] = [:]
    /// True while a load or refresh is running. Drives the branded overlay. Navigation no longer
    /// triggers loads (the data is pre-filled at launch), so this only fires on launch, an explicit
    /// refresh, or a data mutation — never on a plain screen change.
    private(set) var isLoading = false

    // MARK: Filters
    var searchText: String = ""
    var selectedNature: TransactionNatureFilter = .all
    var selectedCategory: TransactionCategory?
    var selectedAccountId: UUID?
    var availableAccounts: [AccountDisplayItem] = []

    var hasActiveFilters: Bool {
        selectedNature != .all || selectedCategory != nil || selectedAccountId != nil
    }

    /// Only transactions whose date has arrived and that belong in the list. Future-dated ones
    /// (scheduled recurrences) are hidden until their day passes; initial balances live on their account.
    private var effectiveTransactions: [Transaction] {
        transactions.filter { $0.isEffective() && $0.category.isListed }
    }

    /// Categories present in the current transaction list, excluding internal ones.
    var availableCategories: [TransactionCategory] {
        let used = Set(effectiveTransactions.map(\.category))
        return TransactionCategory.allCases.filter { used.contains($0) && $0.isUserSelectable }
    }

    func resetFilters() {
        selectedNature = .all
        selectedCategory = nil
        selectedAccountId = nil
    }

    /// Transactions grouped and filtered by the active pickers and search text.
    var listItems: [TransactionListItem] {
        TransactionListItem.group(effectiveTransactions).filter { item in
            passesNature(item) && passesCategory(item) && passesAccount(item) && passesSearch(item)
        }
    }

    private func passesNature(_ item: TransactionListItem) -> Bool {
        switch selectedNature {
        case .all: return true
        case .transfer: return { if case .transfer = item { return true }; return false }()
        case .expense:
            guard case .single(let transaction) = item else { return false }
            return transaction.isExpense && transaction.category != .transfer
        case .income:
            guard case .single(let transaction) = item else { return false }
            return !transaction.isExpense && transaction.category != .transfer
        }
    }

    private func passesCategory(_ item: TransactionListItem) -> Bool {
        guard let category = selectedCategory else { return true }
        guard case .single(let transaction) = item else { return false }
        return transaction.category == category
    }

    private func passesSearch(_ item: TransactionListItem) -> Bool {
        guard !searchText.isEmpty else { return true }
        let query = searchText.lowercased()
        switch item {
        case .single(let transaction):  return transaction.label.lowercased().contains(query)
        case .transfer(let transfer):   return transfer.label.lowercased().contains(query)
        }
    }

    private func passesAccount(_ item: TransactionListItem) -> Bool {
        guard let accountId = selectedAccountId else { return true }
        switch item {
        case .single(let transaction):
            return transaction.belongs(to: accountId)
        case .transfer(let transfer):
            return transfer.source.belongs(to: accountId)
                || transfer.destination.belongs(to: accountId)
        }
    }

    /// Transactions bucketed into time sections (today, this week, this month, then one per past month).
    var sections: [TransactionSection] {
        let calendar = Calendar.current
        let now = Date()
        var buckets: [String: (order: Int, items: [TransactionListItem])] = [:]

        for item in listItems {
            let date = item.date
            let key: String
            let order: Int

            if calendar.isDateInToday(date) {
                key = "Aujourd'hui"
                order = 0
            } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
                key = "Cette semaine"
                order = 1
            } else if calendar.isDate(date, equalTo: now, toGranularity: .month) {
                key = "Ce mois"
                order = 2
            } else {
                let dateComponents = calendar.dateComponents([.year, .month], from: date)
                let year = dateComponents.year ?? 2000
                let month = dateComponents.month ?? 1
                key = Calendar.monthYearLabel(for: date)
                // Newer months get a lower order so they appear first after "Ce mois"
                order = 3 + (3000 - year) * 12 + (12 - month)
            }

            if buckets[key] == nil {
                buckets[key] = (order, [])
            }
            buckets[key]!.items.append(item)
        }

        return buckets
            .map { TransactionSection(id: $0.key, title: $0.key, items: $0.value.items) }
            .sorted { buckets[$0.id]!.order < buckets[$1.id]!.order }
    }

    private let toasty: ToastyManager
    private let getTransactions: GetTransactions
    private let deleteTransaction: DeleteTransaction
    private let getAccount: GetAccount
    private let getAccountsWithInstitution: GetAccountsWithInstitution
    private let refreshFromRemote: RefreshFromRemote
    private let userId: UUID

    /// - Parameters:
    ///   - toasty: Toaster to display message to user.
    ///   - getTransactions: UseCase for fetching all transactions.
    ///   - deleteTransaction: UseCase for deleting one transaction.
    ///   - getAccount: UseCase for resolving a single account name.
    ///   - getAccountsWithInstitution: UseCase for building the flat list of AccountDisplayItem.
    ///   - refreshFromRemote: UseCase warming the remote data before a user-triggered reload.
    ///   - userId: The identifier of the current user.
    init(toasty: ToastyManager,
         getTransactions: GetTransactions,
         deleteTransaction: DeleteTransaction,
         getAccount: GetAccount,
         getAccountsWithInstitution: GetAccountsWithInstitution,
         refreshFromRemote: RefreshFromRemote,
         userId: UUID) {
        self.toasty = toasty
        self.getTransactions = getTransactions
        self.deleteTransaction = deleteTransaction
        self.getAccount = getAccount
        self.getAccountsWithInstitution = getAccountsWithInstitution
        self.refreshFromRemote = refreshFromRemote
        self.userId = userId
    }

    /// Loads all transactions and available filter accounts for the current user.
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            transactions = try await getTransactions.execute(for: userId)

            let allItems = try await getAccountsWithInstitution.execute(for: userId, filter: .all)
            let sortedItems = AccountRecencySorter.sort(allItems, using: transactions)
            availableAccounts = sortedItems.filter { !$0.account.isArchived }
            institutionNames = Dictionary(uniqueKeysWithValues: allItems.map { ($0.account.id, $0.institutionName) })

            for transaction in transactions {
                await loadAccountNames(for: transaction)
            }
        } catch {
            toasty.showError(error)
        }
    }

    /// Pulls fresh data from the remote backend, then reloads from the warmed cache.
    /// Triggered by an explicit user action (pull-to-refresh). A failed remote pull surfaces a
    /// toast but still reloads whatever the cache holds.
    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await refreshFromRemote.execute()
        } catch {
            toasty.showError(error)
        }
        await load()
    }

    /// Deletes a transaction by its identifier.
    func delete(_ transaction: Transaction) async {
        do {
            try await deleteTransaction.execute(id: transaction.id)
            transactions.removeAll { $0.id == transaction.id }
        } catch {
            toasty.showError(error)
        }
    }

    /// Deletes both legs of a transfer and removes them from the local list.
    func deleteTransfer(_ transfer: Transfer) async {
        do {
            try await deleteTransaction.execute(id: transfer.source.id)
            try await deleteTransaction.execute(id: transfer.destination.id)
            transactions.removeAll { $0.id == transfer.source.id || $0.id == transfer.destination.id }
        } catch {
            toasty.showError(error)
        }
    }

    /// Resolves the account name for each split of a transaction and stores them in `accountNames`.
    func loadAccountNames(for transaction: Transaction) async {
        for split in transaction.splits {
            guard accountNames[split.accountId] == nil else { continue }
            if let account = try? await getAccount.execute(id: split.accountId) {
                accountNames[split.accountId] = account.name
            }
        }
    }
}
