//
//  UserRemoteSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation
import FirebaseAuth

/// Handles all Firebase operations for the User feature.
final class UserRemoteSource {

    /// Signs in anonymously via Firebase Auth if no session currently exists.
    /// - Returns: The Firebase Auth uid of the current user.
    /// - Throws: A Firebase Auth error if sign-in fails.
    func signInAnonymously() async throws -> String {
        if let currentUser = Auth.auth().currentUser {
            return currentUser.uid
        }
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }
}
