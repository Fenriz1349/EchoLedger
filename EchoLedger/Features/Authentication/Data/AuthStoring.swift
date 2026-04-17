//
//  AuthStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/04/2026.
//

import Foundation

/// Concrete implementation of `AuthProviding` that coordinates local and remote authentication sources.
final class AuthStoring: AuthProviding {

    private let local: AuthLocalSource
    private let remote: AuthRemoteSource

    init(local: AuthLocalSource, remote: AuthRemoteSource) {
        self.local = local
        self.remote = remote
    }

    /// Resolves the session by reusing a locally stored user ID, or creates a new anonymous session.
    func resolveSession() async throws -> AuthSession {
        if let existingId = local.fetchUserId() {
            _ = try? await remote.signInAnonymously() // maintenir la session Firebase
            return AuthSession(userId: existingId, isAnonymous: true)
        }

        guard (try? await remote.signInAnonymously()) != nil else {
            throw AuthError.signInFailed
        }
        let newId = UUID()
        local.saveUserId(newId)
        return AuthSession(userId: newId, isAnonymous: true)
    }

    /// Signs out from Firebase and clears the locally stored user ID.
    func signOut() async throws {
        do {
            try remote.signOut()
            local.clearUserId()
        } catch {
            throw AuthError.signOutFailed
        }
    }
}
