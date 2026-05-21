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

    /// Loads all transactions for the current user.
    func load() async {
        isLoading = true

        do {
            transactions = try await getTransactions.execute(for: userId)
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
