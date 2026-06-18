//
//  InstitutionCloudStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation
import FirebaseFirestoreInternal

/// Firebase-only implementation of InstitutionProviding.
/// Delegates all reads and writes directly to InstitutionRemoteSource, with no local cache.
final class InstitutionCloudStoring: InstitutionProviding {

    private let remote: InstitutionRemoteSource
    private let userId: UUID
    private let networkMonitor: NetworkMonitor

    init(remote: InstitutionRemoteSource, userId: UUID, networkMonitor: NetworkMonitor) {
        self.remote = remote
        self.userId = userId
        self.networkMonitor = networkMonitor
    }

    // Reads stay cache-first and work offline; only writes are gated, so Firestore never
    // queues a write the user believes was cancelled.

    func fetchAll(for userId: UUID) async throws -> [Institution] {
        try await remote.fetchAll(for: userId, source: .cache)
    }

    func fetch(by id: UUID) async throws -> Institution {
        try await remote.fetch(by: id, userId: userId)
    }

    func save(_ institution: Institution) async throws {
        try await networkMonitor.verifyReachable()
        try await remote.save(institution, userId: userId)
    }

    func update(_ institution: Institution) async throws {
        try await networkMonitor.verifyReachable()
        try await remote.update(institution, userId: userId)
    }

    func archive(by id: UUID) async throws {
        try await networkMonitor.verifyReachable()
        try await remote.archive(id: id, userId: userId)
    }

    func unarchive(by id: UUID) async throws {
        try await networkMonitor.verifyReachable()
        try await remote.unarchive(id: id, userId: userId)
    }

    func delete(by id: UUID) async throws {
        try await networkMonitor.verifyReachable()
        try await remote.delete(id: id, userId: userId)
    }
}

// MARK: - RemoteRefreshable

extension InstitutionCloudStoring: RemoteRefreshable {

    /// Warms the Firestore cache with a fresh server read of all institutions.
    func refreshFromRemote() async throws {
        _ = try await remote.fetchAll(for: userId, source: .server)
    }
}
