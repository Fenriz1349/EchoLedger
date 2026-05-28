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
struct Transaction: Identifiable, Equatable, Codable, Hashable {

    let id: UUID
    let userId: UUID
    let label: String
    let date: Date
    let totalAmount: Double
    let note: String?
    let isExpense: Bool
    let category: TransactionCategory
    let splits: [TransactionSplit]
    /// URL of the photo attached to this transaction (receipt, invoice, etc.). Nil if no photo.
    let photoURL: String?
    /// Date of the last local modification. Nil for records created before sync was introduced.
    let updatedAt: Date?

    /// Creates a new Transaction.
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - userId: The identifier of the User this transaction belongs to.
    ///   - label: Human-readable name for the transaction.
    ///   - date: Date the transaction occurred.
    ///   - totalAmount: Always positive. Use isExpense to determine direction.
    ///   - note: Optional additional information.
    ///   - isExpense: True if this is an expense, false if it is income.
    ///   - category: Category of the transaction.
    ///   - splits: Ventilation of the total amount across accounts. Must not be empty.
    ///   - updatedAt: Last modification date. Nil for legacy records.
    init(id: UUID = UUID(),
         userId: UUID,
         label: String,
         date: Date,
         totalAmount: Double,
         note: String? = nil,
         isExpense: Bool,
         category: TransactionCategory,
         splits: [TransactionSplit],
         photoURL: String? = nil,
         updatedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.label = label
        self.date = date
        self.totalAmount = totalAmount
        self.note = note
        self.isExpense = isExpense
        self.category = category
        self.splits = splits
        self.photoURL = photoURL
        self.updatedAt = updatedAt
    }
}
