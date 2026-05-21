//
//  UserStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Concrete implementation of UserProviding.
/// Reads from local storage, with a remote fallback if the local cache is empty.
/// Writes to local first, then remote.
final class UserStoring: UserProviding {

    private let local: UserLocalSource
    private let remote: UserRemoteSource
    private let userId: UUID

    /// - Parameters:
    ///   - local: The local SwiftData data source.
    ///   - remote: The Firestore remote data source.
    ///   - userId: The internal user identifier used for remote fallback.
    init(local: UserLocalSource, remote: UserRemoteSource, userId: UUID) {
        self.local = local
        self.remote = remote
        self.userId = userId
    }

    /// Fetches the current user from local storage, filtered by userId.
    /// Falls back to Firestore if the local cache has no matching user, then saves the result locally.
    func fetchCurrent() async throws -> User {
        if let user = try? local.fetchCurrent(by: userId) {
            return user
        }
        guard let user = await remote.fetchUser(id: userId) else {
            throw UserError.notFound
        }
        try local.save(user)
        return user
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
