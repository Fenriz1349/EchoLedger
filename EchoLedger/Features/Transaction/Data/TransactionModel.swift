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

    // MARK: Properties
    var id: UUID
    var userId: UUID
    var label: String
    var date: Date
    var totalAmount: Decimal
    var note: String?
    var isExpense: Bool
    var type: String

    // MARK: Relationships
    @Relationship(deleteRule: .cascade)
    var splits: [TransactionSplitModel]

    // MARK: Init
    /// Creates a new TransactionModel from primitive values.
    init(
        id: UUID = UUID(),
        userId: UUID,
        label: String,
        date: Date,
        totalAmount: Decimal,
        note: String? = nil,
        isExpense: Bool,
        type: String
    ) {
        self.id = id
        self.userId = userId
        self.label = label
        self.date = date
        self.totalAmount = totalAmount
        self.note = note
        self.isExpense = isExpense
        self.type = type
        self.splits = []
    }

    // MARK: Mapping
    /// Converts this SwiftData model to a Domain Transaction entity.
    func toDomain() -> Transaction? {
        guard let transactionType = TransactionType(rawValue: type) else { return nil }
        return Transaction(
            id: id,
            userId: userId,
            label: label,
            date: date,
            totalAmount: totalAmount,
            note: note,
            isExpense: isExpense,
            type: transactionType,
            splits: splits.map { $0.toDomain() }
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
        self.type = transaction.type.rawValue

        splits.forEach { context.delete($0) }
        self.splits = transaction.splits.map {
            TransactionSplitModel(id: $0.id, accountId: $0.accountId, amount: $0.amount)
        }
    }
}
