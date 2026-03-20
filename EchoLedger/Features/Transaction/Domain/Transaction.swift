//
//  Transaction.swift
//  EchoLedger
//
//  Created by Julien Cotte on 18/11/2025.
//

import Foundation

/// Represents a real-world financial event (e.g. a restaurant meal).
/// Belongs directly to a User. Account relationships are managed via splits.
/// The total amount is always positive — isExpense determines the direction.
/// A transaction must always have at least one associated TransactionSplit.
struct Transaction: Identifiable, Equatable, Codable {

    // MARK: Properties
    let id: UUID
    let userId: UUID
    let label: String
    let date: Date
    let totalAmount: Decimal
    let note: String?
    let isExpense: Bool
    let type: TransactionType
    let splits: [TransactionSplit]

    // MARK: Init
    /// Creates a new Transaction.
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - userId: The identifier of the User this transaction belongs to.
    ///   - label: Human-readable name for the transaction.
    ///   - date: Date the transaction occurred.
    ///   - totalAmount: Always positive. Use isExpense to determine direction.
    ///   - userId: The Id of the User related to this transaction.
    ///   - note: Optional additional information.
    ///   - isExpense: True if this is an expense, false if it is income.
    ///   - type: Category of the transaction.
    ///   - splits: Ventilation of the total amount across accounts. Must not be empty.
    init(
        id: UUID = UUID(),
        userId: UUID,
        label: String,
        date: Date,
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
