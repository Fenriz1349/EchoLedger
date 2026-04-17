//
//  AuthRemoteSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/04/2026.
//

import Foundation
import FirebaseAuth

/// Handles remote Firebase authentication operations.
final class AuthRemoteSource {

    /// Signs in anonymously, reusing the existing Firebase session if available.
    /// Returns the Firebase user UID.
    func signInAnonymously() async throws -> String {
        if let currentUser = Auth.auth().currentUser {
            return currentUser.uid
        }
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }

    /// Signs out the current Firebase user.
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
