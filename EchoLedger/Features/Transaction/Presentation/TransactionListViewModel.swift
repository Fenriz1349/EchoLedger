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

    /// Transactions grouped into display items — transfer pairs are merged into a single `.transfer` item.
    var listItems: [TransactionListItem] {
        TransactionListItem.group(transactions)
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
                let comps = calendar.dateComponents([.year, .month], from: date)
                let year = comps.year ?? 2000
                let month = comps.month ?? 1
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
    private let userId: UUID

    /// - Parameters:
    ///   - toasty: Toaster to display message to user.
    ///   - getTransactions: UseCase for fetching all transactions.
    ///   - deleteTransaction:UseCase for deleting one transaction..
    ///   - userId: The identifier of the current user.
    init(toasty: ToastyManager,
         getTransactions: GetTransactions,
         deleteTransaction: DeleteTransaction,
         getAccount: GetAccount,
         userId: UUID) {
        self.toasty = toasty
        self.getTransactions = getTransactions
        self.deleteTransaction = deleteTransaction
        self.getAccount = getAccount
        self.userId = userId
    }

    /// Loads all transactions for the current user and resolves account names for all splits.
    func load() async {
        isLoading = true
        do {
            transactions = try await getTransactions.execute(for: userId)
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
