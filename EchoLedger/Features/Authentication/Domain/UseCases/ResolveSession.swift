//
//  ResolveSession.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/04/2026.
//

import Foundation

/// Use case that resolves or creates the current authentication session.
final class ResolveSession {

    private let repository: AuthProviding

    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// Executes the session resolution and returns the active session.
    func execute() async throws -> AuthSession {
        try await repository.resolveSession()
    }
}
