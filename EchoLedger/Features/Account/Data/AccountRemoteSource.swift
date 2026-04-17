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
    
    // MARK: Read

    /// Fetches all accounts for a given institution from Firestore.
    func fetchAll(for institutionId: UUID, userId: UUID) async throws -> [Account] {
        let snapshot = try await collection(for: userId)
            .whereField("institutionId", isEqualTo: institutionId.uuidString)
            .getDocuments()
        return snapshot.documents.compactMap { decode($0.data()) }
    }

    /// Fetches all active accounts for a given institution from Firestore.
    func fetchAllActive(for institutionId: UUID, userId: UUID) async throws -> [Account] {
        try await fetchAll(for: institutionId, userId: userId).filter { !$0.isArchived }
    }

    /// Fetches all archived accounts for a given institution from Firestore.
    func fetchAllArchived(for institutionId: UUID, userId: UUID) async throws -> [Account] {
        try await fetchAll(for: institutionId, userId: userId).filter { $0.isArchived }
    }

    /// Fetches a single account by its identifier from Firestore.
    func fetch(by id: UUID, userId: UUID) async throws -> Account {
        let document = try await collection(for: userId).document(id.uuidString).getDocument()
        guard let data = document.data(), let account = decode(data) else {
            throw AccountError.notFound
        }
        return account
    }

    // MARK: Private

    private func decode(_ data: [String: Any]) -> Account? {
        guard
            let idString = data["id"] as? String,
            let id = UUID(uuidString: idString),
            let institutionIdString = data["institutionId"] as? String,
            let institutionId = UUID(uuidString: institutionIdString),
            let name = data["name"] as? String,
            let categoryRaw = data["category"] as? String,
            let category = AccountCategory(rawValue: categoryRaw),
            let isArchived = data["isArchived"] as? Bool
        else { return nil }

        return Account(id: id, institutionId: institutionId, name: name,
                       category: category, isArchived: isArchived)
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
