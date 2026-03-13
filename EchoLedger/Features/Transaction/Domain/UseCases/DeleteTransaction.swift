//
//  DeleteTransaction.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

// MARK: - DeleteTransaction
/// Handles the deletion of a transaction and all its associated splits.
final class DeleteTransaction {

    // MARK: Dependencies
    private let repository: TransactionRepositoryProtocol

    // MARK: Init
    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: Execute
    /// Deletes a transaction and its splits permanently.
    /// - Parameter id: The unique identifier of the transaction to delete.
    /// - Throws: `TransactionError.notFound` if no transaction matches the identifier.
    func execute(id: UUID) async throws {
        try await repository.delete(by: id)
    }
}
