//
//  UpdateTransaction.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

// MARK: - UpdateTransaction
/// Handles updating an existing transaction and its splits.
/// Supports adding, removing, or modifying splits.
/// Re-enforces all business rules before persisting.
final class UpdateTransaction {

    // MARK: Dependencies
    private let repository: TransactionRepositoryProtocol

    // MARK: Init
    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: Execute
    /// Updates an existing transaction with new values and splits.
    /// - Parameters:
    ///   - id: The unique identifier of the transaction to update.
    ///   - label: Updated human-readable name.
    ///   - date: Updated date of the transaction.
    ///   - totalAmount: Updated total amount, must be strictly positive.
    ///   - note: Updated optional additional information.
    ///   - isExpense: Updated direction — true for expense, false for income.
    ///   - type: Updated category.
    ///   - splits: Updated ventilation. Must not be empty and must sum to totalAmount.
    /// - Throws: `TransactionError` if any business rule is violated.
    func execute(
        id: UUID,
        label: String,
        date: Date,
        totalAmount: Decimal,
        note: String? = nil,
        isExpense: Bool,
        type: TransactionType,
        splits: [TransactionSplit]
    ) async throws {
        guard !label.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw TransactionError.emptyLabel
        }
        guard totalAmount > 0 else {
            throw TransactionError.invalidTotalAmount
        }
        guard !splits.isEmpty else {
            throw TransactionError.missingSplits
        }
        guard splits.allSatisfy({ $0.amount > 0 }) else {
            throw TransactionError.invalidSplitAmount
        }
        guard splits.map(\.amount).reduce(0, +) == totalAmount else {
            throw TransactionError.splitAmountMismatch
        }

        let updated = Transaction(
            id: id,
            label: label,
            date: date,
            totalAmount: totalAmount,
            note: note,
            isExpense: isExpense,
            type: type,
            splits: splits
        )

        try await repository.update(updated)
    }
}
