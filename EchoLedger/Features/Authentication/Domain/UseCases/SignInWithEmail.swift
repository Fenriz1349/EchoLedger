//
//  SignInWithEmail.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import Foundation

/// Signs in an existing user using email and password.
final class SignInWithEmail {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to sign in.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: An `AuthSession` for the authenticated user.
    func execute(email: String, password: String) async throws -> AuthSession {
        try await repository.signInWithEmail(email: email, password: password)
    }
}
