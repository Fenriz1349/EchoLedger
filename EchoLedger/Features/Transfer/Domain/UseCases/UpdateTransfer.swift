//
//  UpdateTransfer.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import Foundation

/// Updates both legs of an existing internal transfer with new values.
/// Preserves the original transaction identifiers while replacing all other fields.
final class UpdateTransfer {

    private let repository: TransactionProviding

    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    /// Updates both legs of an existing transfer with new values.
    /// - Parameters:
    ///   - transfer: The existing transfer whose legs will be updated.
    ///   - input: The new transfer parameters.
    /// - Throws: `TransactionError.invalidTotalAmount` if the amount is not strictly positive.
    func execute(_ transfer: Transfer, input: TransferFormInput) async throws {
        guard input.amount > 0 else { throw TransactionError.invalidTotalAmount }

        let updatedExpense = Transaction(
            id: transfer.source.id,
            userId: input.userId,
            label: input.label,
            date: input.date,
            totalAmount: input.amount,
            isExpense: true,
            category: .transfer,
            splits: [TransactionSplit(accountId: input.sourceAccountId, amount: input.amount)],
            updatedAt: Date()
        )
        let updatedIncome = Transaction(
            id: transfer.destination.id,
            userId: input.userId,
            label: input.label,
            date: input.date,
            totalAmount: input.amount,
            isExpense: false,
            category: .transfer,
            splits: [TransactionSplit(accountId: input.destinationAccountId, amount: input.amount)],
            updatedAt: Date()
        )
        try await repository.update(updatedExpense)
        try await repository.update(updatedIncome)
    }
}
