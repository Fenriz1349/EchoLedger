//
//  AuthRemoteSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/04/2026.
//

import Foundation
import FirebaseAuth

/// Handles all Firebase Auth remote operations.
final class AuthRemoteSource {

    /// Signs in anonymously, reusing the existing Firebase session if available.
    /// - Returns: The Firebase UID of the current user.
    func signInAnonymously() async throws -> String {
        if let currentUser = Auth.auth().currentUser {
            return currentUser.uid
        }
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }

    /// Signs in an existing user with email and password.
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: The Firebase UID of the authenticated user.
    func signInWithEmail(email: String, password: String) async throws -> String {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.user.uid
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    /// Creates a new Firebase Auth account with email and password.
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: The Firebase UID of the newly created user.
    func createAccount(email: String, password: String) async throws -> String {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return result.user.uid
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    /// Links the current anonymous Firebase user to an email/password credential.
    /// - Parameters:
    ///   - email: The email address for the new permanent account.
    ///   - password: The password for the new permanent account.
    func linkAnonymousToEmail(email: String, password: String) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw AuthError.noSessionFound
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        do {
            try await currentUser.link(with: credential)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    /// Deletes the current Firebase Auth user.
    func deleteCurrentUser() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw AuthError.noSessionFound
        }
        do {
            try await currentUser.delete()
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }

    /// Signs out the current Firebase user.
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    /// Sends a Firebase password reset email to the given address.
    /// - Parameter email: The email address of the account to reset.
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            throw AuthError.resetPasswordFailed
        }
    }

    // MARK: Private

    private func mapFirebaseError(_ error: NSError) -> AuthError {
        switch AuthErrorCode(rawValue: error.code) {
        case .emailAlreadyInUse:                return .emailAlreadyInUse
        case .weakPassword:                     return .weakPassword
        case .wrongPassword, .invalidCredential,
             .userNotFound, .invalidEmail:      return .invalidCredentials
        default:                                return .signInFailed
        }
    }
}
