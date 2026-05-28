//
//  InstitutionStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Concrete implementation of InstitutionProviding.
/// Orchestrates local and remote persistence for the Institution feature.
/// Local storage is always used for reads — data is kept up to date via SyncManager.
final class InstitutionStoring: InstitutionProviding {

    private let local: InstitutionLocalSource
    private let remote: InstitutionRemoteSource
    private let userId: UUID

    /// - Parameters:
    ///   - local: The local SwiftData data source.
    ///   - remote: The remote Firestore data source.
    ///   - userId: The identifier of the current user.
    init(local: InstitutionLocalSource, remote: InstitutionRemoteSource, userId: UUID) {
        self.local = local
        self.remote = remote
        self.userId = userId
    }

    /// Fetches all institutions for a given user from local storage.
    func fetchAll(for userId: UUID) async throws -> [Institution] {
        try local.fetchAll(for: userId)
    }

    /// Fetches a single institution by id from local storage.
    func fetch(by id: UUID) async throws -> Institution {
        try local.fetch(by: id)
    }

    /// Persists a new institution to local storage, then attempts a remote save.
    func save(_ institution: Institution) async throws {
        try local.save(institution)
        try await remote.save(institution, userId: userId)
    }

    /// Updates an existing institution in local storage, then attempts a remote update.
    func update(_ institution: Institution) async throws {
        try local.update(institution)
        try await remote.update(institution, userId: userId)
    }

    /// Archives an institution locally, then remotely.
    func archive(by id: UUID) async throws {
        try local.archive(by: id)
        try await remote.archive(id: id, userId: userId)
    }

    /// Restores an archived institution to active status locally, then remotely.
    func unarchive(by id: UUID) async throws {
        try local.unarchive(by: id)
        try await remote.unarchive(id: id, userId: userId)
    }

    /// Deletes an institution from local storage, then attempts a remote delete.
    func delete(by id: UUID) async throws {
        try local.delete(by: id)
        try await remote.delete(id: id, userId: userId)
    }
}
