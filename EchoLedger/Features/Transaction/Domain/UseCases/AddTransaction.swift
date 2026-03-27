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
    /// - Parameter input: The data required to create the transaction.
    /// - Throws: `TransactionError` if any business rule is violated.
    func execute(_ input: AddTransactionInput) async throws {
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

        let transaction = Transaction(
            userId: input.userId,
            label: input.label,
            date: input.date,
            totalAmount: input.totalAmount,
            note: input.note,
            isExpense: input.isExpense,
            category: input.category,
            splits: input.splits
        )
        try await repository.save(transaction)
    }
}
