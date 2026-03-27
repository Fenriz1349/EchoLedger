//
//  TransactionListViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 27/03/2026.
//

import Foundation

@MainActor
@Observable
final class TransactionListViewModel {

    var transactions: [Transaction] = []
    var isLoading = false
    var errorMessage: String? = nil

    private let getTransactions: GetTransactions
    private let userId: UUID

    /// - Parameters:
    ///   - getTransactions: UseCase for fetching all transactions.
    ///   - userId: The identifier of the current user.
    init(getTransactions: GetTransactions, userId: UUID) {
        self.getTransactions = getTransactions
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
}
