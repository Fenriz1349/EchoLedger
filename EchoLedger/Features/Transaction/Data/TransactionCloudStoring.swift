//
//  TransactionCloudStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation
import FirebaseFirestoreInternal

/// Firebase-only implementation of TransactionProviding.
/// Delegates all reads and writes directly to TransactionRemoteSource, with no local cache.
final class TransactionCloudStoring: TransactionProviding {

    private let remote: TransactionRemoteSource
    private let userId: UUID
    private let networkMonitor: NetworkMonitor

    init(remote: TransactionRemoteSource, userId: UUID, networkMonitor: NetworkMonitor) {
        self.remote = remote
        self.userId = userId
        self.networkMonitor = networkMonitor
    }

    /// Fetches all transactions from the local cache (works offline).
    func fetchAll(for userId: UUID) async throws -> [Transaction] {
        try await remote.fetchAll(for: userId, source: .cache)
    }

    /// Fetches a single transaction by its identifier.
    func fetch(by id: UUID) async throws -> Transaction {
        try await remote.fetch(by: id, userId: userId)
    }

    /// Persists a new transaction remotely. Throws `OfflineError` if unreachable, so the write is
    /// cancelled before Firestore can queue it offline.
    func save(_ transaction: Transaction) async throws {
        try await networkMonitor.verifyReachable()
        try await remote.save(transaction, userId: userId)
    }

    /// Updates an existing transaction remotely. Gated on reachability like `save`.
    func update(_ transaction: Transaction) async throws {
        try await networkMonitor.verifyReachable()
        try await remote.update(transaction, userId: userId)
    }

    /// Deletes a transaction remotely. Gated on reachability like `save`.
    func delete(by id: UUID) async throws {
        try await networkMonitor.verifyReachable()
        try await remote.delete(id: id, userId: userId)
    }
}

// MARK: - RemoteRefreshable

extension TransactionCloudStoring: RemoteRefreshable {

    /// Warms the Firestore cache with a fresh server read of all transactions.
    func refreshFromRemote() async throws {
        _ = try await remote.fetchAll(for: userId, source: .server)
    }
}
