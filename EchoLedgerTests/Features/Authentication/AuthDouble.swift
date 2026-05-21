//
//  AuthDouble.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 30/04/2026.
//

import Foundation
@testable import EchoLedger

/// In-memory mock implementation of AuthProviding.
/// Used exclusively in unit tests to isolate use cases from Firebase and local storage.
final class AuthDouble: AuthProviding {

    // MARK: Stub Values
    var sessionToReturn = AuthSession(userId: UUID(), isAnonymous: false)
    var isExpired = false
    var daysRemaining: Int?

    // MARK: Spy Properties
    /// Tracks whether expireAnonymousSession() was called.
    var didCallExpire = false

    /// Tracks whether deleteAccount() was called.
    var didCallDeleteAccount = false

    /// Tracks whether signOut() was called.
    var didCallSignOut = false

    // MARK: Error Simulation
    var errorToThrow: Error?

    // MARK: AuthProviding

    func resolveSession() async throws -> AuthSession {
        if let error = errorToThrow { throw error }
        return sessionToReturn
    }

    func signInWithEmail(email: String, password: String) async throws -> AuthSession {
        if let error = errorToThrow { throw error }
        return sessionToReturn
    }

    func createAccount(email: String,
                       password: String,
                       firstName: String,
                       lastName: String) async throws -> AuthSession {
        if let error = errorToThrow { throw error }
        return sessionToReturn
    }

    func signInAnonymously() async throws -> AuthSession {
        if let error = errorToThrow { throw error }
        return sessionToReturn
    }

    func signOut() async throws {
        if let error = errorToThrow { throw error }
        didCallSignOut = true
    }

    func deleteAccount() async throws {
        if let error = errorToThrow { throw error }
        didCallDeleteAccount = true
    }

    func linkAnonymousAccount(toEmail email: String,
                              password: String,
                              firstName: String,
                              lastName: String) async throws -> AuthSession {
        if let error = errorToThrow { throw error }
        return sessionToReturn
    }

    func resetPassword(email: String) async throws {
        if let error = errorToThrow { throw error }
    }

    func isAnonymousSessionExpired() -> Bool {
        isExpired
    }

    func anonymousDaysRemaining() -> Int? {
        daysRemaining
    }

    func expireAnonymousSession() async {
        didCallExpire = true
    }
}
