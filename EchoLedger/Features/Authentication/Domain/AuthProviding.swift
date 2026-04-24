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
    /// - Returns: The stored `AuthSession`, or throws `AuthError.noSessionFound` if none exists.
    func resolveSession() async throws -> AuthSession

    /// Signs in an existing user with email and password.
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: An `AuthSession` for the authenticated user.
    func signInWithEmail(email: String, password: String) async throws -> AuthSession

    /// Creates a new account with email, password, and display name.
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - firstName: The user's first name.
    ///   - lastName: The user's last name.
    /// - Returns: An `AuthSession` for the newly created user.
    func createAccount(email: String, password: String, firstName: String, lastName: String) async throws -> AuthSession

    /// Signs in anonymously, creating a demo session without a permanent account.
    /// - Returns: An anonymous `AuthSession`.
    func signInAnonymously() async throws -> AuthSession

    /// Signs out the current user and clears the local session.
    func signOut() async throws

    /// Permanently deletes the current user account and all associated remote data.
    func deleteAccount() async throws

    /// Links the current anonymous account to a permanent email/password account.
    /// - Parameters:
    ///   - email: The email address for the new permanent account.
    ///   - password: The password for the new permanent account.
    /// - Returns: An updated non-anonymous `AuthSession`.
    func linkAnonymousAccount(toEmail email: String, password: String) async throws -> AuthSession
}
