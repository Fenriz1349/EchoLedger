//
//  DeletedEntityCloudStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 29/07/2026.
//

import Foundation

/// Firebase-only implementation of DeletedEntityProviding.
/// Delegates all reads and writes directly to DeletedEntityRemoteSource, with no local cache.
final class DeletedEntityCloudStoring: DeletedEntityProviding {

    private let remote: DeletedEntityRemoteSource
    private let userId: UUID
    private let networkMonitor: NetworkMonitor

    init(remote: DeletedEntityRemoteSource, userId: UUID, networkMonitor: NetworkMonitor) {
        self.remote = remote
        self.userId = userId
        self.networkMonitor = networkMonitor
    }

    /// Saves a deleted-entity trace remotely. Throws `OfflineError` if unreachable, so the write
    /// is cancelled before Firestore can queue it offline.
    func save(_ entity: DeletedEntity) async throws {
        try await networkMonitor.verifyReachable()
        try await remote.save(entity, userId: userId)
    }

    /// Fetches a deleted entity's trace by its identifier.
    func fetch(by id: UUID) async throws -> DeletedEntity? {
        try await remote.fetch(by: id, userId: userId)
    }

    /// Purges every deleted-entity trace remotely. Gated on reachability like `save`.
    func purge() async throws {
        try await networkMonitor.verifyReachable()
        try await remote.purge(userId: userId)
    }
}
