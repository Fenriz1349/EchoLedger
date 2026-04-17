//
//  TransactionStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Concrete implementation of TransactionProviding.
/// Orchestrates local and remote persistence for the Transaction feature.
final class TransactionStoring: TransactionProviding {

    private let local: TransactionLocalSource
    private let remote: TransactionRemoteSource
    private let userId: UUID

    /// - Parameters:
    ///   - local: The local SwiftData data source.
    ///   - remote: The remote Firestore data source.
    ///   - userId: The identifier of the current user.
    init(local: TransactionLocalSource, remote: TransactionRemoteSource, userId: UUID) {
        self.local = local
        self.remote = remote
        self.userId = userId
    }

    /// Fetches all transactions for a given user from local storage.
    func fetchAll(for userId: UUID) async throws -> [Transaction] {
        try local.fetchAll(for: userId)
    }

    /// Fetches a single transaction by id from local storage.
    func fetch(by id: UUID) async throws -> Transaction {
        try local.fetch(by: id)
    }

    /// Persists a new transaction and its splits to local storage, then attempts a remote save.
    /// - Parameter transaction: The transaction to save.
    /// - Throws: A local persistence error if the local save fails.
    func save(_ transaction: Transaction) async throws {
        try local.save(transaction)
        try await remote.save(transaction, userId: userId)
    }

    /// Updates an existing transaction and its splits in local storage, then attempts a remote update.
    /// - Parameter transaction: The transaction with updated values.
    /// - Throws: A local persistence error if the local update fails.
    func update(_ transaction: Transaction) async throws {
        try local.update(transaction)
        try? await remote.update(transaction, userId: userId)
    }

    /// Deletes a transaction and its splits from local storage, then attempts a remote delete.
    /// - Parameter id: The unique identifier of the transaction to delete.
    /// - Throws: A local persistence error if the local delete fails.
    func delete(by id: UUID) async throws {
        try local.delete(by: id)
        try? await remote.delete(id: id, userId: userId)
    }
}
