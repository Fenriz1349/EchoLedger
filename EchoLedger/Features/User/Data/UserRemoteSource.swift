//
//  UserRemoteSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation
import FirebaseAuth

// MARK: - UserRemoteDataSource
/// Handles all Firebase operations for the User feature.
final class UserRemoteSource {

    // MARK: Authentication

    /// Signs in anonymously via Firebase Auth.
    /// - Returns: The Firebase uid of the anonymous user.
    func signInAnonymously() async throws -> String {
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }
}
