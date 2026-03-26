//
//  AddTransactionInput.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import Foundation

/// Encapsulates all parameters required to create a new transaction.
struct AddTransactionInput {
    let userId: UUID
    let label: String
    let date: Date
    let totalAmount: Decimal
    let note: String?
    let isExpense: Bool
    let type: TransactionType
    let splits: [TransactionSplit]

    /// Creates a new AddTransactionInput.
    /// - Parameters:
    ///   - userId: The identifier of the user this transaction belongs to.
    ///   - label: Human-readable name for the transaction.
    ///   - date: Date the transaction occurred.
    ///   - totalAmount: Always positive. Use isExpense to determine direction.
    ///   - note: Optional additional information.
    ///   - isExpense: True if this is an expense, false if income.
    ///   - type: Category of the transaction.
    ///   - splits: Ventilation across accounts. Must not be empty and must sum to totalAmount.
    init(
        userId: UUID,
        label: String,
        date: Date = Date(),
        totalAmount: Decimal,
        note: String? = nil,
        isExpense: Bool,
        type: TransactionType,
        splits: [TransactionSplit]
    ) {
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
