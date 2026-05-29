//
//  Transaction.swift
//  EchoLedger
//
//  Created by Julien Cotte on 18/11/2025.
//

import SwiftUI

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
    /// URL of the attachment (photo or PDF) linked to this transaction. Nil if no attachment.
    let attachmentURL: String?
    /// Standard MIME type of the attachment (e.g. "image/jpeg", "application/pdf"). Nil if no attachment.
    let attachmentContentType: String?
    /// Date of the last local modification. Nil for records created before sync was introduced.
    let updatedAt: Date?

    init(id: UUID = UUID(),
         userId: UUID,
         label: String,
         date: Date,
         totalAmount: Double,
         note: String? = nil,
         isExpense: Bool,
         category: TransactionCategory,
         splits: [TransactionSplit],
         attachmentURL: String? = nil,
         attachmentContentType: String? = nil,
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
        self.attachmentURL = attachmentURL
        self.attachmentContentType = attachmentContentType
        self.updatedAt = updatedAt
    }
}

extension Transaction {

    /// Color to display in Transactions lists
    var color: Color {
        if self.category == .initialBalance && self.isExpense {
            return .red
        } else if !self.isExpense {
            return .green
        } else {
            return .primary
        }
    }
}
