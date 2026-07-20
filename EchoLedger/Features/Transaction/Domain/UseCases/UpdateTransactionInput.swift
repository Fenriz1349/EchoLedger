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
    let totalAmount: Double
    let note: String?
    let isExpense: Bool
    let category: TransactionCategory
    let splits: [TransactionSplit]
    /// Current attachment URL to preserve, or nil to clear it.
    let attachmentURL: String?
    /// Current attachment MIME type to preserve, or nil to clear it.
    let attachmentContentType: String?

    init(
        id: UUID,
        userId: UUID,
        label: String,
        date: Date,
        totalAmount: Double,
        note: String?,
        isExpense: Bool,
        category: TransactionCategory,
        splits: [TransactionSplit],
        attachmentURL: String? = nil,
        attachmentContentType: String? = nil
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
    }
}
