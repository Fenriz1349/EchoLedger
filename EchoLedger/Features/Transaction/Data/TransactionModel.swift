//
//  TransactionModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/03/2026.
//

import Foundation
import SwiftData

/// SwiftData persistent model for Transaction.
/// Maps to and from the Domain Transaction entity via TransactionLocalDataSource.
@Model
final class TransactionModel {

    var id: UUID
    var userId: UUID
    var label: String
    var date: Date
    var totalAmount: Double
    var note: String?
    var isExpense: Bool
    var category: String
    var photoURL: String?
    var updatedAt: Date?

    @Relationship(deleteRule: .cascade)
    var splits: [TransactionSplitModel]

    /// Creates a new TransactionModel from primitive values.
    init(id: UUID = UUID(),
         userId: UUID,
         label: String,
         date: Date,
         totalAmount: Double,
         note: String? = nil,
         isExpense: Bool,
         category: String,
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
        self.splits = []
        self.updatedAt = updatedAt
    }

    /// Converts this SwiftData model to a Domain Transaction entity.
    func toDomain() -> Transaction? {
        guard let transactionCategory = TransactionCategory(rawValue: category) else { return nil }
        return Transaction(
            id: id,
            userId: userId,
            label: label,
            date: date,
            totalAmount: totalAmount,
            note: note,
            isExpense: isExpense,
            category: transactionCategory,
            splits: splits.map { $0.toDomain() },
            photoURL: photoURL,
            updatedAt: updatedAt
        )
    }

    /// Updates this model's properties from a Domain Transaction entity.
    /// - Parameter transaction: The domain entity with updated values.
    func update(from transaction: Transaction, context: ModelContext) {
        self.label = transaction.label
        self.date = transaction.date
        self.totalAmount = transaction.totalAmount
        self.note = transaction.note
        self.isExpense = transaction.isExpense
        self.category = transaction.category.rawValue
        self.photoURL = transaction.photoURL
        self.updatedAt = transaction.updatedAt

        splits.forEach { context.delete($0) }
        self.splits = transaction.splits.map {
            TransactionSplitModel(id: $0.id, accountId: $0.accountId, amount: $0.amount)
        }
    }
}
