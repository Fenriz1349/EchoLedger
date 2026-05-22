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
    var isLoading = false

    // MARK: Filters

    var searchText: String = ""
    var selectedNature: TransactionNatureFilter = .all
    var selectedCategory: TransactionCategory?
    var selectedAccountId: UUID?
    var availableAccounts: [Account] = []

    var hasActiveFilters: Bool {
        selectedNature != .all || selectedCategory != nil || selectedAccountId != nil
    }

    /// Categories present in the current transaction list, excluding internal ones.
    var availableCategories: [TransactionCategory] {
        let used = Set(transactions.map(\.category))
        return TransactionCategory.allCases.filter { used.contains($0) && $0.isUserSelectable }
    }

    func resetFilters() {
        selectedNature = .all
        selectedCategory = nil
        selectedAccountId = nil
    }

    /// Transactions grouped and filtered by the active pickers and search text.
    var listItems: [TransactionListItem] {
        TransactionListItem.group(transactions).filter { item in
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
            return transaction.splits.contains { $0.accountId == accountId }
        case .transfer(let transfer):
            return transfer.source.splits.contains { $0.accountId == accountId }
                || transfer.destination.splits.contains { $0.accountId == accountId }
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
                key = date.formatted(.dateTime.month(.wide).year()).capitalized
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
    private let getInstitutions: GetInstitutions
    private let getAccounts: GetAccounts
    private let userId: UUID

    /// - Parameters:
    ///   - toasty: Toaster to display message to user.
    ///   - getTransactions: UseCase for fetching all transactions.
    ///   - deleteTransaction: UseCase for deleting one transaction.
    ///   - getAccount: UseCase for resolving a single account name.
    ///   - getInstitutions: UseCase for fetching institutions (used to load filter accounts).
    ///   - getAccounts: UseCase for fetching accounts per institution.
    ///   - userId: The identifier of the current user.
    init(toasty: ToastyManager,
         getTransactions: GetTransactions,
         deleteTransaction: DeleteTransaction,
         getAccount: GetAccount,
         getInstitutions: GetInstitutions,
         getAccounts: GetAccounts,
         userId: UUID) {
        self.toasty = toasty
        self.getTransactions = getTransactions
        self.deleteTransaction = deleteTransaction
        self.getAccount = getAccount
        self.getInstitutions = getInstitutions
        self.getAccounts = getAccounts
        self.userId = userId
    }

    /// Loads all transactions and available filter accounts for the current user.
    func load() async {
        isLoading = true
        do {
            async let transactionsResult = getTransactions.execute(for: userId)
            async let institutionsResult = getInstitutions.execute(for: userId)

            let (fetchedTransactions, institutions) = try await (transactionsResult, institutionsResult)
            transactions = fetchedTransactions

            var accounts: [Account] = []
            for institution in institutions {
                let institutionAccounts = try await getAccounts.execute(for: institution.id, filter: .all)
                accounts.append(contentsOf: institutionAccounts)
            }
            availableAccounts = accounts.sorted { $0.name < $1.name }

            for transaction in transactions {
                await loadAccountNames(for: transaction)
            }
        } catch {
            toasty.showError(error)
        }
        isLoading = false
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
