//
//  UpdateTransaction.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Handles updating an existing transaction and its embedded splits.
/// Supports adding, removing, or modifying splits.
/// Re-enforces all business rules before persisting.
final class UpdateTransaction {

    private let repository: TransactionProviding

    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    /// Updates an existing transaction with new values and splits.
    /// - Parameter input: The data required to update the transaction.
    /// - Throws: `TransactionError` if any business rule is violated.
    func execute(_ input: UpdateTransactionInput) async throws {
        guard !input.label.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw TransactionError.emptyLabel
        }
        guard input.totalAmount > 0 else {
            throw TransactionError.invalidTotalAmount
        }
        guard !input.splits.isEmpty else {
            throw TransactionError.missingSplits
        }
        guard input.splits.allSatisfy({ $0.amount > 0 }) else {
            throw TransactionError.invalidSplitAmount
        }
        guard input.splits.map(\.amount).reduce(0, +) == input.totalAmount else {
            throw TransactionError.splitAmountMismatch
        }

        let updated = Transaction(
            id: input.id,
            userId: input.userId,
            label: input.label,
            date: input.date,
            totalAmount: input.totalAmount,
            note: input.note,
            isExpense: input.isExpense,
            category: input.category,
            splits: input.splits
        )
        try await repository.update(updated)
    }
}
