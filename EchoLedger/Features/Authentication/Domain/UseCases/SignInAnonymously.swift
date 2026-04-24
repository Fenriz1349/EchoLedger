//
//  SignInAnonymously.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import Foundation

/// Signs in anonymously to start a demo session without a permanent account.
final class SignInAnonymously {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to sign in anonymously.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// - Returns: An anonymous `AuthSession`.
    func execute() async throws -> AuthSession {
        try await repository.signInAnonymously()
    }
}
