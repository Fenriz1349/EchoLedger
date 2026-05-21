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
            try? remote.signOut()
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
    func createAccount(email: String,
                       password: String,
                       firstName: String,
                       lastName: String) async throws -> AuthSession {
        let firebaseUID = try await remote.createAccount(email: email, password: password)
        let userId = UUID()
        let user = User(id: userId, displayName: "\(firstName)|\(lastName)", email: email)

        do {
            try await userRemote.save(user, firebaseUID: firebaseUID)
        } catch {
            throw AuthError.signInFailed
        }

        local.saveUserId(userId)
        return AuthSession(userId: userId, isAnonymous: false)
    }

    /// Signs in anonymously, reusing the local UUID if available, and records the creation date.
    func signInAnonymously() async throws -> AuthSession {
        let firebaseUID = try await remote.signInAnonymously()

        if let existingId = local.fetchUserId() {
            return AuthSession(userId: existingId, isAnonymous: true)
        }

        let newId = UUID()
        let anonymousUser = User(id: newId, displayName: "Anonyme", email: "")
        try? await userRemote.save(anonymousUser, firebaseUID: firebaseUID)
        local.saveUserId(newId)
        local.saveAnonymousCreationDate()
        return AuthSession(userId: newId, isAnonymous: true)
    }

    /// Signs out from Firebase and clears the local session.
    func signOut() async throws {
        do {
            try remote.signOut()
            local.clearUserId()
            local.clearAnonymousCreationDate()
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
            local.clearAnonymousCreationDate()
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.deletionFailed
        }
    }

    /// Returns true if the anonymous session was created more than 7 days ago.
    func isAnonymousSessionExpired() -> Bool {
        local.isAnonymousSessionExpired()
    }

    /// Returns the number of days remaining in the anonymous demo session, or nil if no date is stored.
    func anonymousDaysRemaining() -> Int? {
        local.anonymousDaysRemaining()
    }

    /// Deletes the Firebase anonymous account and Firestore data, then clears the local session.
    func expireAnonymousSession() async {
        guard let userId = local.fetchUserId() else { return }
        try? await userRemote.delete(userId: userId)
        try? await remote.deleteCurrentUser()
        local.clearUserId()
        local.clearAnonymousCreationDate()
    }

    /// Links the anonymous Firebase account and creates the permanent user document.
    func linkAnonymousAccount(toEmail email: String,
                              password: String,
                              firstName: String,
                              lastName: String) async throws -> AuthSession {
        guard let userId = local.fetchUserId() else { throw AuthError.noSessionFound }
        do {
            try await remote.linkAnonymousToEmail(email: email, password: password)
            let user = User(id: userId, displayName: "\(firstName)|\(lastName)", email: email)
            if let firebaseUID = Auth.auth().currentUser?.uid {
                try await userRemote.save(user, firebaseUID: firebaseUID)
            }
            return AuthSession(userId: userId, isAnonymous: false)
        } catch let error as AuthError {
            throw error
        } catch {
            throw AuthError.accountLinkingFailed
        }
    }

    /// Delegates password reset to the remote authentication source.
    func resetPassword(email: String) async throws {
        try await remote.resetPassword(email: email)
    }
}
