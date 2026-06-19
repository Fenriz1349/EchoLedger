//
//  AuthProviding.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/04/2026.
//

import Foundation

/// Defines the contract for all authentication operations.
protocol AuthProviding {

    /// Resolves an existing session from local storage without creating a new one.
    /// - Returns: The stored `AuthSession`, or nil if none exists (absence, not an error).
    func resolveSession() async -> AuthSession?

    /// Signs in an existing user with email and password.
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: An `AuthSession` for the authenticated user.
    func signInWithEmail(email: String, password: String) async throws -> AuthSession

    /// Creates a new profile with email, password, and display name.
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - firstName: The user's first name.
    ///   - lastName: The user's last name.
    /// - Returns: An `AuthSession` for the newly created user.
    func createUserProfile(email: String,
                           password: String,
                           firstName: String,
                           lastName: String) async throws -> AuthSession

    /// Signs in anonymously, creating a demo session without a permanent account.
    /// - Returns: An anonymous `AuthSession`.
    func signInAnonymously() async throws -> AuthSession

    /// Signs out the current user and clears the local session.
    func signOut() async throws

    /// Permanently deletes the current user account and all associated remote data.
    func deleteUserProfile() async throws

    /// Links the current anonymous account to a permanent email/password account.
    /// - Parameters:
    ///   - email: The email address for the new permanent account.
    ///   - password: The password for the new permanent account.
    ///   - firstName: The user's first name.
    ///   - lastName: The user's last name.
    /// - Returns: An updated non-anonymous `AuthSession`.
    func linkAnonymousAccount(toEmail email: String,
                              password: String,
                              firstName: String,
                              lastName: String) async throws -> AuthSession

    /// Sends a password reset email to the given address.
    /// - Parameter email: The email address of the account to reset.
    func resetPassword(email: String) async throws

    /// Returns true if the current anonymous session was created more than 7 days ago.
    func isAnonymousSessionExpired() -> Bool

    /// Returns the number of days remaining in the anonymous demo session, or nil if not anonymous.
    func anonymousDaysRemaining() -> Int?

    /// Deletes the Firebase anonymous account and Firestore data, then clears local session state.
    func expireAnonymousSession() async
}
