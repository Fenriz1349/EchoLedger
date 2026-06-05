//
//  PreviewAuthStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/04/2026.
//

import Foundation

/// No-op AuthProviding implementation for SwiftUI previews.
final class PreviewAuthStoring: AuthProviding {
    func resolveSession() async throws -> AuthSession { PreviewData.authSession }
    func signInWithEmail(email: String, password: String) async throws -> AuthSession { PreviewData.authSession }
    func createUserProfil(email: String, password: String, firstName: String, lastName: String) async throws -> AuthSession {
        PreviewData.authSession
    }
    func signInAnonymously() async throws -> AuthSession { PreviewData.authSession }
    func signOut() async throws {}
    func deleteUserProfil() async throws {}
    func linkAnonymousAccount(toEmail email: String, password: String, firstName: String, lastName: String) async throws -> AuthSession {
        PreviewData.authSession
    }
    func resetPassword(email: String) async throws {}
    func isAnonymousSessionExpired() -> Bool { false }
    func anonymousDaysRemaining() -> Int? { 3 }
    func expireAnonymousSession() async {}
}
