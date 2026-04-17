//
//  AuthProviding.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/04/2026.
//

import Foundation

/// Defines the contract for authentication operations.
protocol AuthProviding {

    /// Resolves or creates the current user session.
    func resolveSession() async throws -> AuthSession

    /// Signs out the current user and clears the session.
    func signOut() async throws
}
