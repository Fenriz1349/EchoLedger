//
//  DeleteUserProfile.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import Foundation

/// Deletes the Firebase Auth account and clears the local session. The very last step of full
/// account deletion, orchestrated by `DeleteUserRule` — by this point Storage and Firestore data
/// are already gone, so the Auth account is the only thing left.
final class DeleteUserProfile {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to delete the account.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// Deletes the Auth account and clears the local session.
    func execute() async throws {
        try await repository.deleteUserProfile()
    }
}
