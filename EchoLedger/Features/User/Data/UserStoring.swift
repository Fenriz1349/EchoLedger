//
//  UserStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Concrete implementation of UserProviding.
/// Reads from local storage only. Writes to local first, then remote.
final class UserStoring: UserProviding {

    private let local: UserLocalSource
    private let remote: UserRemoteSource

    /// - Parameters:
    ///   - local: The local SwiftData data source.
    ///   - remote: The Firestore remote data source.
    init(local: UserLocalSource, remote: UserRemoteSource) {
        self.local = local
        self.remote = remote
    }

    /// Fetches the current user from local storage.
    func fetchCurrent() async throws -> User {
        try local.fetchCurrent()
    }

    /// Persists a new user to local storage only.
    func save(_ user: User) async throws {
        try local.save(user)
    }

    /// Updates an existing user in local storage, then syncs to Firestore.
    func update(_ user: User) async throws {
        try local.update(user)
        try await remote.update(user)
    }

    /// Deletes a user and all associated local data via cascade.
    func delete(by id: UUID) async throws {
        try local.delete(by: id)
    }
}
