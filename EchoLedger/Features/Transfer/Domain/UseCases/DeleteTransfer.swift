//
//  DeleteTransfer.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import Foundation

/// Deletes both legs of an internal transfer (expense + income) atomically.
final class DeleteTransfer {

    private let repository: TransactionProviding

    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    /// Deletes both legs of a transfer.
    /// - Parameter transfer: The transfer whose expense and income legs will be deleted.
    /// - Throws: `TransactionError.notFound` if either transaction cannot be found.
    func execute(_ transfer: Transfer) async throws {
        try await repository.delete(by: transfer.source.id)
        try await repository.delete(by: transfer.destination.id)
    }
}
