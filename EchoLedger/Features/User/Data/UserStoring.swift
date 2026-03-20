//
//  UserStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Concrete implementation of UserProviding.
final class UserStoring: UserProviding {

    // MARK: Dependencies
    private let local: UserLocalSource

    // MARK: Init
    /// - Parameter local: The local SwiftData data source.
    init(local: UserLocalSource) {
        self.local = local
    }

    // MARK: UserProviding

    /// Fetches the current user from local storage.
    func fetchCurrent() async throws -> User {
        try local.fetchCurrent()
    }

    /// Persists a new user to local storage.
    func save(_ user: User) async throws {
        try local.save(user)
    }

    /// Updates an existing user in local storage.
    func update(_ user: User) async throws {
        try local.update(user)
    }

    /// Deletes a user from local storage.
    func delete(by id: UUID) async throws {
        try local.delete(by: id)
    }
}
