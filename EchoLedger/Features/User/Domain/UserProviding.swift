//
//  UserProviding.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Defines the contract for user persistence.
/// The Domain layer depends only on this protocol — it has no knowledge of SwiftData or Firebase.
/// Conforming types live in the Data layer.
protocol UserProviding {

    /// Fetches the current authenticated user.
    /// - Returns: The current user.
    func fetchCurrent() async throws -> User

    /// Persists a new user.
    /// - Parameter user: The user to save.
    func save(_ user: User) async throws

    /// Updates an existing user.
    /// - Parameter user: The user with updated values.
    func update(_ user: User) async throws

    /// Deletes a user and all associated data permanently.
    /// - Parameter id: The internal unique identifier of the user to delete.
    func delete(by id: UUID) async throws
}
