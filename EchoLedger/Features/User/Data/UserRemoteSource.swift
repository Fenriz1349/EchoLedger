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

    /// Creates a new user document in Firestore, storing the Firebase UID for multi-device sign-in.
    /// - Parameters:
    ///   - user: The domain User to persist remotely.
    ///   - firebaseUID: The Firebase Auth UID used to retrieve the internal UUID on a new device.
    func save(_ user: User, firebaseUID: String) async throws {
        var data = encode(user)
        data["firebaseUID"] = firebaseUID
        try await document(for: user.id).setData(data)
    }

    /// Updates an existing user document in Firestore. Does not overwrite the firebaseUID field.
    /// - Parameter user: The domain User with updated values.
    func update(_ user: User) async throws {
        try await document(for: user.id).setData(encode(user), merge: true)
    }

    /// Adds the Firebase UID to an existing user document. Used when linking an anonymous account.
    /// - Parameters:
    ///   - firebaseUID: The Firebase Auth UID to store.
    ///   - userId: The internal UUID of the user.
    func linkFirebaseUID(_ firebaseUID: String, toUserId userId: UUID) async throws {
        try await document(for: userId).setData(["firebaseUID": firebaseUID], merge: true)
    }

    /// Fetches the internal UUID for a user by their Firebase UID.
    /// Used when signing in on a new device where UserDefaults has been cleared.
    /// - Parameter firebaseUID: The Firebase Auth UID to look up.
    /// - Returns: The internal UUID if found, nil otherwise.
    func fetchInternalUserId(forFirebaseUID firebaseUID: String) async -> UUID? {
        guard let snapshot = try? await firestore.collection("users")
            .whereField("firebaseUID", isEqualTo: firebaseUID)
            .limit(to: 1)
            .getDocuments(),
              let data = snapshot.documents.first?.data(),
              let idString = data["id"] as? String
        else { return nil }
        return UUID(uuidString: idString)
    }

    /// Fetches a user document from Firestore by internal UUID.
    /// - Parameter userId: The internal UUID of the user to fetch.
    /// - Returns: The domain User, or nil if the document does not exist or cannot be decoded.
    func fetchUser(id userId: UUID) async -> User? {
        guard let data = try? await document(for: userId).getDocument().data() else { return nil }
        return decode(data)
    }

    /// Deletes the user document from Firestore.
    /// - Parameter userId: The identifier of the user to delete.
    func delete(userId: UUID) async throws {
        try await document(for: userId).delete()
    }

    // MARK: Private

    private func decode(_ data: [String: Any]) -> User? {
        guard
            let idString = data["id"] as? String,
            let id = UUID(uuidString: idString),
            let displayName = data["displayName"] as? String,
            let email = data["email"] as? String
        else { return nil }
        return User(id: id, displayName: displayName, email: email, photoURL: data["photoURL"] as? String)
    }

    private func encode(_ user: User) -> [String: Any] {
        var data: [String: Any] = [
            "id": user.id.uuidString,
            "displayName": user.displayName,
            "email": user.email,
            "photoURL": user.photoURL as Any
        ]
        if user.photoURL == nil {
            data["photoURL"] = FieldValue.delete()
        }
        return data
    }
}
