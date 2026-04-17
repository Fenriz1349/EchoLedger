//
//  SignOut.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/04/2026.
//

import Foundation

/// Use case that signs out the current user and clears the session.
final class SignOut {

    private let repository: AuthProviding

    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// Executes the sign-out operation.
    func execute() async throws {
        try await repository.signOut()
    }
}
