//
//  ResetPassword.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import Foundation

/// Sends a password reset email to the given address.
final class ResetPassword {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to send the reset email.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// - Parameter email: The email address of the account to reset.
    func execute(email: String) async throws {
        try await repository.resetPassword(email: email)
    }
}
