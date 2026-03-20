//
//  TransactionStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Concrete implementation of TransactionProviding.
final class TransactionStoring: TransactionProviding {

    // MARK: Dependencies
    private let local: TransactionLocalSource

    // MARK: Init
    /// - Parameter local: The local SwiftData data source.
    init(local: TransactionLocalSource) {
        self.local = local
    }

    // MARK: TransactionProviding

    /// Fetches all transactions for a given user from local storage.
    func fetchAll(for userId: UUID) async throws -> [Transaction] {
        try local.fetchAll(for: userId)
    }

    /// Fetches a single transaction by id from local storage.
    func fetch(by id: UUID) async throws -> Transaction {
        try local.fetch(by: id)
    }

    /// Persists a new transaction and its splits to local storage.
    func save(_ transaction: Transaction) async throws {
        try local.save(transaction)
    }

    /// Updates an existing transaction and its splits in local storage.
    func update(_ transaction: Transaction) async throws {
        try local.update(transaction)
    }

    /// Deletes a transaction and its splits from local storage.
    func delete(by id: UUID) async throws {
        try local.delete(by: id)
    }
}
