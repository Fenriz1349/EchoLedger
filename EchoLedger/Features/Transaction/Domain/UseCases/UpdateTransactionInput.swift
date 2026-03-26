//
//  UpdateTransactionInput.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation

/// Encapsulates all parameters required to update an existing transaction.
struct UpdateTransactionInput {
    let id: UUID
    let userId: UUID
    let label: String
    let date: Date
    let totalAmount: Decimal
    let note: String?
    let isExpense: Bool
    let type: TransactionType
    let splits: [TransactionSplit]

    /// Creates a new UpdateTransactionInput.
    /// - Parameters:
    ///   - id: The unique identifier of the transaction to update.
    ///   - userId: The identifier of the user this transaction belongs to.
    ///   - label: Updated human-readable name.
    ///   - date: Updated date of the transaction.
    ///   - totalAmount: Updated total amount, must be strictly positive.
    ///   - note: Updated optional additional information.
    ///   - isExpense: Updated direction — true for expense, false for income.
    ///   - type: Updated category.
    ///   - splits: Updated ventilation. Must not be empty and must sum to totalAmount.
    init(
        id: UUID,
        userId: UUID,
        label: String,
        date: Date = Date(),
        totalAmount: Decimal,
        note: String? = nil,
        isExpense: Bool,
        type: TransactionType,
        splits: [TransactionSplit]
    ) {
        self.id = id
        self.userId = userId
        self.label = label
        self.date = date
        self.totalAmount = totalAmount
        self.note = note
        self.isExpense = isExpense
        self.type = type
        self.splits = splits
    }
}
