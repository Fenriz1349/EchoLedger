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

    /// Updates the expense and income transactions of a transfer.
    /// - Parameters:
    ///   - expenseId: The identifier of the expense leg to update.
    ///   - incomeId: The identifier of the income leg to update.
    ///   - input: The new transfer parameters.
    /// - Throws: `TransactionError.invalidTotalAmount` if the amount is not strictly positive.
    func execute(expenseId: UUID, incomeId: UUID, input: TransferInput) async throws {
        guard input.amount > 0 else { throw TransactionError.invalidTotalAmount }

        let updatedExpense = Transaction(
            id: expenseId,
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
            id: incomeId,
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
