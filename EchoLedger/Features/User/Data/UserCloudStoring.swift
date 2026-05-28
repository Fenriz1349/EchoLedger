//
//  UserCloudStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Firebase-only implementation of UserProviding.
/// Delegates all reads and writes directly to UserRemoteSource, with no local cache.
final class UserCloudStoring: UserProviding {

    private let remote: UserRemoteSource
    private let userId: UUID
    private let firebaseUID: String

    init(remote: UserRemoteSource, userId: UUID, firebaseUID: String) {
        self.remote = remote
        self.userId = userId
        self.firebaseUID = firebaseUID
    }

    func fetchCurrent() async throws -> User {
        guard let user = await remote.fetchUser(id: userId) else {
            throw UserError.notFound
        }
        return user
    }

    func save(_ user: User) async throws {
        try await remote.save(user, firebaseUID: firebaseUID)
    }

    func update(_ user: User) async throws {
        try await remote.update(user)
    }

    func delete(by id: UUID) async throws {
        try await remote.delete(userId: id)
    }
}
