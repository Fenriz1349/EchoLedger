//
//  DeleteTransaction.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Handles the deletion of a transaction and all its associated splits.
final class DeleteTransaction {

    private let repository: TransactionProviding

    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    /// Deletes a transaction and its splits permanently.
    /// - Parameter id: The unique identifier of the transaction to delete.
    /// - Throws: `TransactionError.notFound` if no transaction matches the identifier.
    func execute(id: UUID) async throws {
        try await repository.delete(by: id)
    }
}
