//
//  CreateUserProfile.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import Foundation

/// Creates a new permanent user profile with email, password, and display name.
final class CreateUserProfile {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to create the account.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - firstName: The user's first name.
    ///   - lastName: The user's last name.
    /// - Returns: An `AuthSession` for the newly created user.
    func execute(email: String, password: String, firstName: String, lastName: String) async throws -> AuthSession {
        try await repository.createUserProfile(email: email,
                                               password: password,
                                               firstName: firstName,
                                               lastName: lastName)
    }
}
