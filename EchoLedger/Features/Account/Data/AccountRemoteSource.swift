//
//  AccountRemoteSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation
import FirebaseFirestore

/// Handles all Firestore read and write operations for the Account feature.
final class AccountRemoteSource {

    private lazy var firestore = Firestore.firestore()

    private func collection(for userId: UUID) -> CollectionReference {
        firestore.collection("users").document(userId.uuidString)
            .collection("accounts")
    }

    // MARK: Write

    /// Saves a new account to Firestore.
    /// - Parameters:
    ///   - account: The domain Account to persist remotely.
    ///   - userId: The identifier of the owning user.
    /// - Throws: A Firestore error if the write fails.
    func save(_ account: Account, userId: UUID) async throws {
        try await collection(for: userId)
            .document(account.id.uuidString)
            .setData(encode(account))
    }

    /// Updates an existing account in Firestore.
    /// - Parameters:
    ///   - account: The domain Account with updated values.
    ///   - userId: The identifier of the owning user.
    /// - Throws: A Firestore error if the write fails.
    func update(_ account: Account, userId: UUID) async throws {
        try await collection(for: userId)
            .document(account.id.uuidString)
            .setData(encode(account), merge: true)
    }

    // MARK: Private

    /// Encodes a domain Account into a Firestore-compatible dictionary.
    /// - Parameter account: The account to encode.
    /// - Returns: A dictionary representation of the account.
    private func encode(_ account: Account) -> [String: Any] {
        [
            "id": account.id.uuidString,
            "institutionId": account.institutionId.uuidString,
            "name": account.name,
            "category": account.category.rawValue,
            "isArchived": account.isArchived
        ]
    }
}
