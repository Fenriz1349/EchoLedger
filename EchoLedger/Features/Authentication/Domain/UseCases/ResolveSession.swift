//
//  ResolveSession.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/04/2026.
//

import Foundation

/// Attempts to restore an existing authentication session from local storage.
final class ResolveSession {

    private let repository: AuthProviding

    /// - Parameter repository: The authentication provider used to resolve the session.
    init(repository: AuthProviding) {
        self.repository = repository
    }

    /// Executes the session resolution.
    /// - Returns: The existing `AuthSession`, or nil if no session is stored.
    func execute() async -> AuthSession? {
        await repository.resolveSession()
    }
}
