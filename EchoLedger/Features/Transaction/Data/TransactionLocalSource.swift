//
//  TransactionLocalSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation
import SwiftData

// MARK: - TransactionLocalSource
/// Handles all SwiftData read and write operations for the Transaction feature.
final class TransactionLocalSource {

    // MARK: Properties
    private let context: ModelContext

    // MARK: Init
    /// - Parameter context: The SwiftData model context used for persistence.
    init(context: ModelContext) {
        self.context = context
    }

    // MARK: Read

    /// Fetches all transactions belonging to a given user, ordered by date descending.
    /// - Parameter userId: The internal UUID of the user.
    /// - Returns: An array of Domain Transaction entities.
    func fetchAll(for userId: UUID) throws -> [Transaction] {
        let descriptor = FetchDescriptor<TransactionModel>(
            predicate: #Predicate { $0.userId == userId },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor).compactMap { $0.toDomain() }
    }

    /// Fetches a single transaction by its internal identifier.
    /// - Parameter id: The internal UUID of the transaction.
    /// - Returns: The matching Domain Transaction entity.
    func fetch(by id: UUID) throws -> Transaction {
        var descriptor = FetchDescriptor<TransactionModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let model = try context.fetch(descriptor).first else {
            throw TransactionError.notFound
        }
        guard let transaction = model.toDomain() else {
            throw TransactionError.notFound
        }
        return transaction
    }

    // MARK: Write

    /// Persists a new transaction and its splits locally.
    /// - Parameter transaction: The domain Transaction to save.
    func save(_ transaction: Transaction) throws {
        let model = TransactionModel(
            id: transaction.id,
            userId: transaction.userId,
            label: transaction.label,
            date: transaction.date,
            totalAmount: transaction.totalAmount,
            note: transaction.note,
            isExpense: transaction.isExpense,
            category: transaction.category.rawValue
        )
        model.splits = transaction.splits.map {
            TransactionSplitModel(id: $0.id, accountId: $0.accountId, amount: $0.amount)
        }
        context.insert(model)
        try context.save()
    }

    /// Updates an existing transaction and replaces its splits locally.
    /// - Parameter transaction: The domain Transaction with updated values.
    func update(_ transaction: Transaction) throws {
        let id = transaction.id
        var descriptor = FetchDescriptor<TransactionModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let model = try context.fetch(descriptor).first else {
            throw TransactionError.notFound
        }
        model.update(from: transaction, context: context)
        try context.save()
    }

    /// Deletes a transaction and all its associated splits locally.
    /// - Parameter id: The internal UUID of the transaction to delete.
    func delete(by id: UUID) throws {
        var descriptor = FetchDescriptor<TransactionModel>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        guard let model = try context.fetch(descriptor).first else {
            throw TransactionError.notFound
        }
        context.delete(model)
        try context.save()
    }
}
