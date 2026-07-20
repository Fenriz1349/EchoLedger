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

    private let repository: TransactionProviding

    /// - Parameter repository: The data contract for transaction persistence.
    init(repository: TransactionProviding) {
        self.repository = repository
    }

    /// Creates and persists a new transaction.
    /// - Parameter input: The data required to create the transaction.
    /// - Returns: The created transaction, including its generated identifier.
    /// - Throws: `TransactionError` if any business rule is violated.
    @discardableResult
    func execute(_ input: AddTransactionInput) async throws -> Transaction {
        guard !input.label.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw TransactionError.emptyLabel
        }
        // An initial balance entry may be zero (account opened at 0); every other transaction needs a positive amount.
        let allowsZeroAmount = input.category == .initialBalance
        guard allowsZeroAmount ? input.totalAmount >= 0 : input.totalAmount > 0 else {
            throw TransactionError.invalidTotalAmount
        }
        guard !input.splits.isEmpty else {
            throw TransactionError.missingSplits
        }
        guard input.splits.allSatisfy({ allowsZeroAmount ? $0.amount >= 0 : $0.amount > 0 }) else {
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
            splits: input.splits,
            updatedAt: Date()
        )
        try await repository.save(transaction)
        return transaction
    }
}
