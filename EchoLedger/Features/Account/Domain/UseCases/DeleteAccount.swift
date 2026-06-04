//
//  DeleteAccount.swift
//  EchoLedger
//
//  Created by Julien Cotte on 29/05/2026.
//

import Foundation

/// Permanently deletes a bank account and all transactions linked to it.
/// Fetches all user transactions, filters those containing a split for this account,
/// deletes them first, then deletes the account itself.
final class DeleteAccount {

    private let accountRepository: AccountProviding
    private let transactionRepository: TransactionProviding
    private let userId: UUID

    /// - Parameters:
    ///   - accountRepository: The data contract for account persistence.
    ///   - transactionRepository: The data contract for transaction persistence.
    ///   - userId: The identifier of the current user, used to scope the transaction fetch.
    init(accountRepository: AccountProviding,
         transactionRepository: TransactionProviding,
         userId: UUID) {
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
        self.userId = userId
    }

    /// Deletes a bank account and all its linked transactions.
    /// - Parameter id: The unique identifier of the account to delete.
    func execute(id: UUID) async throws {
        let allTransactions = try await transactionRepository.fetchAll(for: userId)
        let linked = allTransactions.filter { $0.splits.contains { $0.accountId == id } }
        for transaction in linked {
            try await transactionRepository.delete(by: transaction.id)
        }
        try await accountRepository.delete(by: id)
    }
}
