//
//  AddTransaction.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Handles the creation of a new transaction with its embedded splits.
/// Enforces all business rules before persisting.
final class AddTransaction {

    // MARK: Dependencies
    private let repository: TransactionProviding

    // MARK: Init
    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    // MARK: Execute
    /// Creates and persists a new transaction.
    /// - Parameters:
    ///   - userId: The identifier of the user this transaction belongs to.
    ///   - label: Human-readable name for the transaction.
    ///   - date: Date the transaction occurred.
    ///   - totalAmount: Total amount, must be strictly positive.
    ///   - note: Optional additional information.
    ///   - isExpense: True if this is an expense, false if income.
    ///   - type: Category of the transaction.
    ///   - splits: Ventilation across accounts. Must not be empty and must sum to totalAmount.
    /// - Throws: `TransactionError` if any business rule is violated.
    func execute(
        userId: UUID,
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

        let transaction = Transaction(
            userId: userId,
            label: label,
            date: date,
            totalAmount: totalAmount,
            note: note,
            isExpense: isExpense,
            type: type,
            splits: splits
        )

        try await repository.save(transaction)
    }
}
