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
    private let deleteDocument: DocumentDeleting
    private let userId: UUID

    /// - Parameters:
    ///   - accountRepository: The data contract for account persistence.
    ///   - transactionRepository: The data contract for transaction persistence.
    ///   - deleteDocument: UseCase for removing each linked transaction's attachment file.
    ///   - userId: The identifier of the current user, used to scope the transaction fetch.
    init(accountRepository: AccountProviding,
         transactionRepository: TransactionProviding,
         deleteDocument: DocumentDeleting,
         userId: UUID) {
        self.accountRepository = accountRepository
        self.transactionRepository = transactionRepository
        self.deleteDocument = deleteDocument
        self.userId = userId
    }

    /// Deletes a bank account, all its linked transactions, and their attachment files.
    /// Each attachment is deleted before its transaction record, so a file is never left
    /// orphaned. A failure aborts the cascade; retrying resumes safely (an already-deleted file
    /// counts as success).
    /// - Parameter id: The unique identifier of the account to delete.
    func execute(id: UUID) async throws {
        let allTransactions = try await transactionRepository.fetchAll(for: userId)
        let linked = allTransactions.filter { $0.splits.contains { $0.accountId == id } }
        for transaction in linked {
            if let attachmentURL = transaction.attachmentURL {
                try await deleteDocument.execute(urlString: attachmentURL)
            }
            try await transactionRepository.delete(by: transaction.id)
        }
        try await accountRepository.delete(by: id)
    }
}
