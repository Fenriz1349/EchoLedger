//
//  UserCloudStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation
import FirebaseFirestore

/// Firebase-only implementation of UserProviding.
/// Delegates all reads and writes directly to UserRemoteSource, with no local cache.
final class UserCloudStoring: UserProviding {

    private let remote: UserRemoteSource
    private let userId: UUID
    private let firebaseUID: String
    private let networkMonitor: NetworkMonitor

    init(remote: UserRemoteSource, userId: UUID, firebaseUID: String, networkMonitor: NetworkMonitor) {
        self.remote = remote
        self.userId = userId
        self.firebaseUID = firebaseUID
        self.networkMonitor = networkMonitor
    }

    /// Fetches the current user, cache-first so an offline launch never hangs waiting on the
    /// server. Falls back to a server read only on a cache miss (e.g. a fresh device), which
    /// fails fast when offline and surfaces as an unreachable error rather than a hang.
    func fetchCurrent() async throws -> User {
        if let cached = try? await remote.fetchUser(id: userId, source: .cache) {
            return cached
        }
        try await networkMonitor.verifyReachable()
        guard let user = try await remote.fetchUser(id: userId, source: .server) else {
            throw UserError.notFound
        }
        return user
    }

    /// Persists a new user document remotely. Throws `OfflineError` if unreachable, so the write is
    /// cancelled before Firestore can queue it offline.
    func save(_ user: User) async throws {
        try await networkMonitor.verifyReachable()
        try await remote.save(user, firebaseUID: firebaseUID)
    }

    /// Updates the user document remotely. Gated on reachability like `save`.
    func update(_ user: User) async throws {
        try await networkMonitor.verifyReachable()
        try await remote.update(user)
    }

    /// Deletes the user document remotely. Gated on reachability like `save`.
    func delete(by id: UUID) async throws {
        try await networkMonitor.verifyReachable()
        try await remote.delete(userId: id)
    }
}
