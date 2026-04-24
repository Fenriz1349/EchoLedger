//
//  AuthStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/04/2026.
//

import Foundation
import FirebaseAuth

/// Coordinates local and remote sources to fulfill all authentication operations.
final class AuthStoring: AuthProviding {

    private let local: AuthLocalSource
    private let remote: AuthRemoteSource
    private let userRemote: UserRemoteSource

    /// - Parameters:
    ///   - local: Local persistence for the internal user UUID.
    ///   - remote: Firebase Auth remote source.
    ///   - userRemote: Firestore remote source for user documents.
    init(local: AuthLocalSource, remote: AuthRemoteSource, userRemote: UserRemoteSource) {
        self.local = local
        self.remote = remote
        self.userRemote = userRemote
    }

    /// Restores an existing session from local storage without creating a new one.
    func resolveSession() async throws -> AuthSession {
        guard let userId = local.fetchUserId() else {
            throw AuthError.noSessionFound
        }
        let isAnonymous = Auth.auth().currentUser?.isAnonymous ?? true
        return AuthSession(userId: userId, isAnonymous: isAnonymous)
    }

    /// Signs in with email and password, restoring the internal UUID from Firestore on a new device.
    func signInWithEmail(email: String, password: String) async throws -> AuthSession {
        let firebaseUID = try await remote.signInWithEmail(email: email, password: password)

        if let existingId = local.fetchUserId() {
            return AuthSession(userId: existingId, isAnonymous: false)
        }

        guard let userId = await userRemote.fetchInternalUserId(forFirebaseUID: firebaseUID) else {
            throw AuthError.noSessionFound
        }
        local.saveUserId(userId)
        return AuthSession(userId: userId, isAnonymous: false)
    }

    /// Creates a Firebase Auth account, generates an internal UUID, and persists the user document.
    func createAccount(email: String, password: String, firstName: String, lastName: String) async throws -> AuthSession {
        let firebaseUID = try await remote.createAccount(email: email, password: password)
        let userId = UUID()
        let user = User(id: userId, displayName: "\(firstName) \(lastName)", email: email)

        do {
            try await userRemote.save(user, firebaseUID: firebaseUID)
        } catch {
            throw AuthError.signInFailed
        }

        local.saveUserId(userId)
        return AuthSession(userId: userId, isAnonymous: false)
    }

    /// Signs in anonymously, reusing the local UUID if available.
    func signInAnonymously() async throws -> AuthSession {
        _ = try await remote.signInAnonymously()

        if let existingId = local.fetchUserId() {
            return AuthSession(userId: existingId, isAnonymous: true)
        }

        let newId = UUID()
        local.saveUserId(newId)
        return AuthSession(userId: newId, isAnonymous: true)
    }

    /// Signs out from Firebase and clears the local session.
    func signOut() async throws {
        do {
            try remote.signOut()
            local.clearUserId()
        } catch {
            throw AuthError.signOutFailed
        }
    }

    /// Deletes the Firestore user document, the Firebase Auth account, and clears the local session.
    func deleteAccount() async throws {
        guard let userId = local.fetchUserId() else {
            throw AuthError.noSessionFound
        }
        do {
            try await userRemote.delete(userId: userId)
            try await remote.deleteCurrentUser()
            local.clearUserId()
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.deletionFailed
        }
    }

    /// Links the anonymous Firebase account to a permanent email/password credential.
    func linkAnonymousAccount(toEmail email: String, password: String) async throws -> AuthSession {
        guard let userId = local.fetchUserId() else {
            throw AuthError.noSessionFound
        }
        do {
            try await remote.linkAnonymousToEmail(email: email, password: password)
            if let firebaseUID = Auth.auth().currentUser?.uid {
                try await userRemote.linkFirebaseUID(firebaseUID, toUserId: userId)
            }
            return AuthSession(userId: userId, isAnonymous: false)
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.accountLinkingFailed
        }
    }
}
