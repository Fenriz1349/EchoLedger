//
//  LinkAnonymousAccount.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import Foundation

/// Links the current anonymous session to a permanent email/password account,
/// preserving all existing user data.
final class LinkAnonymousAccount {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to link the account.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// - Parameters:
    ///   - email: The email address for the new permanent account.
    ///   - password: The password for the new permanent account.
    ///   - firstName: The user's first name.
    ///   - lastName: The user's last name.
    /// - Returns: An updated non-anonymous `AuthSession`.
    func execute(email: String, password: String, firstName: String, lastName: String) async throws -> AuthSession {
        try await repository.linkAnonymousAccount(toEmail: email, password: password, firstName: firstName, lastName: lastName)
    }
}
