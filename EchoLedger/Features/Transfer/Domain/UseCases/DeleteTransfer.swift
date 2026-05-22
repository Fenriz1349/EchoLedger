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

    /// Deletes the expense and income transactions of a transfer.
    /// - Parameters:
    ///   - expenseId: The identifier of the expense leg (source account).
    ///   - incomeId: The identifier of the income leg (destination account).
    /// - Throws: `TransactionError.notFound` if either transaction cannot be found.
    func execute(expenseId: UUID, incomeId: UUID) async throws {
        try await repository.delete(by: expenseId)
        try await repository.delete(by: incomeId)
    }
}
