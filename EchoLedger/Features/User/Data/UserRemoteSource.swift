//
//  UserRemoteSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation
import FirebaseFirestore

/// Handles Firestore read and write operations for the User feature.
final class UserRemoteSource {

    private lazy var firestore = Firestore.firestore()

    private func document(for userId: UUID) -> DocumentReference {
        firestore.collection("users").document(userId.uuidString)
    }

    /// Saves a new user document to Firestore.
    /// - Parameter user: The domain User to persist remotely.
    func save(_ user: User) async throws {
        try await document(for: user.id).setData(encode(user))
    }

    /// Updates an existing user document in Firestore.
    /// - Parameter user: The domain User with updated values.
    func update(_ user: User) async throws {
        try await document(for: user.id).setData(encode(user), merge: true)
    }

    /// Deletes the user document from Firestore.
    /// - Parameter userId: The identifier of the user to delete.
    func delete(userId: UUID) async throws {
        try await document(for: userId).delete()
    }

    // MARK: Private

    private func encode(_ user: User) -> [String: Any] {
        var data: [String: Any] = [
            "id": user.id.uuidString,
            "displayName": user.displayName,
            "email": user.email
        ]
        if let photoURL = user.photoURL {
            data["photoURL"] = photoURL
        }
        return data
    }
}
