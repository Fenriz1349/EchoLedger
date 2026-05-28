//
//  InstitutionRemoteSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation
import FirebaseFirestore

final class InstitutionRemoteSource {

    private lazy var firestore = Firestore.firestore()

    private func collection(for userId: UUID) -> CollectionReference {
        firestore.collection("users").document(userId.uuidString)
          .collection("institutions")
    }

    // MARK: Write

    /// Saves a new institution to Firestore.
    /// - Parameters:
    ///   - institution: The domain Institution to persist remotely.
    ///   - userId: The identifier of the owning user.
    /// - Throws: A Firestore error if the write fails.
    func save(_ institution: Institution, userId: UUID) async throws {
        let data = encode(institution)
        try await collection(for: userId)
            .document(institution.id.uuidString)
            .setData(data)
    }

    /// Updates an existing institution in Firestore.
    /// - Parameters:
    ///   - institution: The domain Institution with updated values.
    ///   - userId: The identifier of the owning user.
    /// - Throws: A Firestore error if the write fails.
    func update(_ institution: Institution, userId: UUID) async throws {
        let data = encode(institution)
        try await collection(for: userId)
            .document(institution.id.uuidString)
            .setData(data, merge: true)
    }

    /// Archives an institution in Firestore by setting `isArchived` to true.
    /// - Parameters:
    ///   - id: The identifier of the institution to archive.
    ///   - userId: The identifier of the owning user.
    /// - Throws: A Firestore error if the write fails.
    func archive(id: UUID, userId: UUID) async throws {
        try await collection(for: userId)
            .document(id.uuidString)
            .setData(["isArchived": true, "updatedAt": Timestamp(date: Date())], merge: true)
    }

    /// Unarchives an institution in Firestore by setting `isArchived` to false.
    /// - Parameters:
    ///   - id: The identifier of the institution to unarchive.
    ///   - userId: The identifier of the owning user.
    /// - Throws: A Firestore error if the write fails.
    func unarchive(id: UUID, userId: UUID) async throws {
        try await collection(for: userId)
            .document(id.uuidString)
            .setData(["isArchived": false, "updatedAt": Timestamp(date: Date())], merge: true)
    }

    /// Deletes an institution from Firestore.
    /// - Parameters:
    ///   - id: The identifier of the institution to delete.
    ///   - userId: The identifier of the owning user.
    /// - Throws: A Firestore error if the write fails.
    func delete(id: UUID, userId: UUID) async throws {
        try await collection(for: userId)
            .document(id.uuidString)
            .delete()
    }

    // MARK: Read

    /// Fetches all institutions for a given user from Firestore.
    /// - Parameter userId: The identifier of the owning user.
    /// - Returns: An array of Domain Institution entities.
    /// - Throws: A Firestore error if the fetch fails.
    func fetchAll(for userId: UUID) async throws -> [Institution] {
        let snapshot = try await collection(for: userId).getDocuments()
        return snapshot.documents.compactMap { decode($0.data()) }
    }

    /// Fetches a single institution by its identifier from Firestore.
    func fetch(by id: UUID, userId: UUID) async throws -> Institution {
        let document = try await collection(for: userId).document(id.uuidString).getDocument()
        guard let data = document.data(), let institution = decode(data) else {
            throw InstitutionError.notFound
        }
        return institution
    }

    // MARK: Private

    private func encode(_ institution: Institution) -> [String: Any] {
        var data: [String: Any] = [
            "id": institution.id.uuidString,
            "userId": institution.userId.uuidString,
            "name": institution.name,
            "category": institution.category.rawValue,
            "logoURL": institution.logoURL as Any,
            "isArchived": institution.isArchived
        ]
        if let updatedAt = institution.updatedAt {
            data["updatedAt"] = Timestamp(date: updatedAt)
        }
        return data
    }

    private func decode(_ data: [String: Any]) -> Institution? {
        guard
            let idString = data["id"] as? String,
            let id = UUID(uuidString: idString),
            let userIdString = data["userId"] as? String,
            let userId = UUID(uuidString: userIdString),
            let name = data["name"] as? String,
            let categoryRaw = data["category"] as? String,
            let category = InstitutionCategory(rawValue: categoryRaw)
        else { return nil }

        return Institution(
            id: id,
            userId: userId,
            name: name,
            category: category,
            logoURL: data["logoURL"] as? String,
            isArchived: data["isArchived"] as? Bool ?? false,
            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue()
        )
    }
}
