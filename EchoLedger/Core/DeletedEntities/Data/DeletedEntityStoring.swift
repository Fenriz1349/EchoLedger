//
//  DeletedEntityStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 29/07/2026.
//

import Foundation

/// Concrete implementation of DeletedEntityProviding.
/// Orchestrates local and remote persistence for the DeletedEntities feature.
/// Local storage is always used for reads — data is kept up to date via SyncManager.
final class DeletedEntityStoring: DeletedEntityProviding {

    private let local: DeletedEntityLocalSource
    private let remote: DeletedEntityRemoteSource
    private let userId: UUID

    /// - Parameters:
    ///   - local: The local SwiftData data source.
    ///   - remote: The remote Firestore data source.
    ///   - userId: The identifier of the current user.
    init(local: DeletedEntityLocalSource, remote: DeletedEntityRemoteSource, userId: UUID) {
        self.local = local
        self.remote = remote
        self.userId = userId
    }

    /// Saves a deleted-entity trace to local storage, then attempts a remote save.
    func save(_ entity: DeletedEntity) async throws {
        try local.save(entity)
        try await remote.save(entity, userId: userId)
    }

    /// Fetches a deleted entity's trace by id from local storage.
    func fetch(by id: UUID) async throws -> DeletedEntity? {
        try local.fetch(by: id)
    }

    /// Purges every deleted-entity trace from local storage, then attempts a remote purge.
    func purge() async throws {
        try local.purge()
        try await remote.purge(userId: userId)
    }
}
