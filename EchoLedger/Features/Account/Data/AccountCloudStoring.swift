//
//  AccountCloudStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation
import FirebaseFirestoreInternal

/// Firebase-only implementation of AccountProviding.
/// Delegates all reads and writes directly to AccountRemoteSource, with no local cache.
final class AccountCloudStoring: AccountProviding {

    private let remote: AccountRemoteSource
    private let userId: UUID
    private let networkMonitor: NetworkMonitor

    init(remote: AccountRemoteSource, userId: UUID, networkMonitor: NetworkMonitor) {
        self.remote = remote
        self.userId = userId
        self.networkMonitor = networkMonitor
    }

    /// Fetches all accounts of an institution from the local cache (works offline).
    func fetchAll(for institutionId: UUID) async throws -> [Account] {
        try await remote.fetchAll(for: institutionId, userId: userId, source: .cache)
    }

    /// Fetches the non-archived accounts of an institution from the local cache.
    func fetchAllActive(for institutionId: UUID) async throws -> [Account] {
        try await remote.fetchAll(for: institutionId, userId: userId, source: .cache).filter { !$0.isArchived }
    }

    /// Fetches the archived accounts of an institution from the local cache.
    func fetchAllArchived(for institutionId: UUID) async throws -> [Account] {
        try await remote.fetchAll(for: institutionId, userId: userId, source: .cache).filter { $0.isArchived }
    }

    /// Fetches a single account by its identifier.
    func fetch(by id: UUID) async throws -> Account {
        try await remote.fetch(by: id, userId: userId)
    }

    /// Persists a new account remotely. Throws `OfflineError` if unreachable, so the write is
    /// cancelled before Firestore can queue it offline.
    func save(_ account: Account) async throws {
        try await networkMonitor.verifyReachable()
        try await remote.save(account, userId: userId)
    }

    /// Updates an existing account remotely. Gated on reachability like `save`.
    func update(_ account: Account) async throws {
        try await networkMonitor.verifyReachable()
        try await remote.update(account, userId: userId)
    }

    /// Deletes an account remotely. Gated on reachability like `save`.
    func delete(by id: UUID) async throws {
        try await networkMonitor.verifyReachable()
        try await remote.delete(id: id, userId: userId)
    }
}

// MARK: - RemoteRefreshable

extension AccountCloudStoring: RemoteRefreshable {

    /// Warms the Firestore cache with a fresh server read of all accounts.
    func refreshFromRemote() async throws {
        _ = try await remote.fetchAll(for: userId, source: .server)
    }
}
