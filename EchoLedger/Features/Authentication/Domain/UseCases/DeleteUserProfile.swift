//
//  DeleteUserProfile.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import Foundation

/// Permanently deletes the current user account and all associated remote data.
final class DeleteUserProfile {

    private let repository: AuthProviding
    private let userStoring: UserProviding
    private let userId: UUID

    /// - Parameters:
    ///   - repository: The authentication provider used to delete the account.
    ///   - userStoring: The user data provider for deleting user data.
    ///   - userId: The internal user identifier.
    init(repository: AuthProviding, userStoring: UserProviding, userId: UUID) {
        self.repository = repository
        self.userStoring = userStoring
        self.userId = userId
    }

    /// Deletes user data, Firebase Auth account, and clears the local session.
    func execute() async throws {
        try? await userStoring.delete(by: userId)
        try await repository.deleteUserProfile()
    }
}
