//
//  InstitutionStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Concrete implementation of InstitutionProviding.
/// Orchestrates local and remote persistence for the Institution feature.
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
    /// - Parameter institution: The institution to save.
    /// - Throws: A local persistence error if the local save fails.
    func save(_ institution: Institution) async throws {
        try local.save(institution)
        try? await remote.save(institution, userId: userId)
    }

    /// Updates an existing institution in local storage, then attempts a remote update.
    /// - Parameter institution: The institution with updated values.
    /// - Throws: A local persistence error if the local update fails.
    func update(_ institution: Institution) async throws {
        try local.update(institution)
        try? await remote.update(institution, userId: userId)
    }

    /// Deletes an institution from local storage, then attempts a remote delete.
    /// - Parameter id: The unique identifier of the institution to delete.
    /// - Throws: A local persistence error if the local delete fails.
    func delete(by id: UUID) async throws {
        try local.delete(by: id)
        try? await remote.delete(id: id, userId: userId)
    }
}
