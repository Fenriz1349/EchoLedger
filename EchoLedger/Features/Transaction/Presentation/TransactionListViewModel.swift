//
//  TransactionListViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 27/03/2026.
//

import Foundation

/// Manages the list of transactions and handles delete operations.
@MainActor
@Observable
final class TransactionListViewModel {

    var showAddTransaction = false
    var transactions: [Transaction] = []
    var isLoading = false
    var errorMessage: String?

    private let getTransactions: GetTransactions
    private let deleteTransaction: DeleteTransaction
    private let userId: UUID

    /// - Parameters:
    ///   - getTransactions: UseCase for fetching all transactions.
    ///   - deleteTransaction:UseCase for deleting one transaction..
    ///   - userId: The identifier of the current user.
    init(getTransactions: GetTransactions, deleteTransaction: DeleteTransaction, userId: UUID) {
        self.getTransactions = getTransactions
        self.deleteTransaction = deleteTransaction
        self.userId = userId
    }

    /// Loads all transactions for the current user.
    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            transactions = try await getTransactions.execute(for: userId)
        } catch {
            errorMessage = "Impossible de charger les transactions"
        }
        isLoading = false
    }

    /// Deletes a transaction by its identifier.
    func delete(_ transaction: Transaction) async {
        do {
            try await deleteTransaction.execute(id: transaction.id)
            transactions.removeAll { $0.id == transaction.id }
        } catch {
            errorMessage = "Impossible de supprimer la transaction"
        }
    }
}
