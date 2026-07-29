//
//  DeletedEntityRemoteSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 29/07/2026.
//

import Foundation
import FirebaseFirestore

/// Handles all Firestore read and write operations for the DeletedEntities feature.
final class DeletedEntityRemoteSource {

    private lazy var firestore = Firestore.firestore()

    private func collection(for userId: UUID) -> CollectionReference {
        firestore.collection("users").document(userId.uuidString)
            .collection("deletedEntities")
    }

    // MARK: Write

    /// Saves a new deleted-entity trace to Firestore.
    /// - Parameters:
    ///   - entity: The domain DeletedEntity to persist remotely.
    ///   - userId: The identifier of the owning user.
    func save(_ entity: DeletedEntity, userId: UUID) async throws {
        try await collection(for: userId)
            .document(entity.id.uuidString)
            .setData(encode(entity))
    }

    /// Permanently removes every deleted-entity trace for a user from Firestore.
    /// - Parameter userId: The identifier of the owning user.
    func purge(userId: UUID) async throws {
        let snapshot = try await collection(for: userId).getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }

    // MARK: Read

    /// Fetches a deleted entity's trace by its original identifier from Firestore.
    /// - Parameters:
    ///   - id: The identifier the entity had before being deleted.
    ///   - userId: The identifier of the owning user.
    /// - Returns: The matching DeletedEntity, or `nil` if no document exists.
    func fetch(by id: UUID, userId: UUID) async throws -> DeletedEntity? {
        let document = try await collection(for: userId).document(id.uuidString).getDocument()
        guard let data = document.data() else { return nil }
        return decode(data)
    }

    // MARK: Private

    /// Decodes a Firestore document dictionary into a domain DeletedEntity.
    /// - Parameter data: The raw Firestore document data.
    /// - Returns: A decoded DeletedEntity, or `nil` if any required field is missing or invalid.
    private func decode(_ data: [String: Any]) -> DeletedEntity? {
        guard
            let idString = data["id"] as? String,
            let id = UUID(uuidString: idString),
            let name = data["name"] as? String,
            let kindRaw = data["kind"] as? String,
            let kind = DeletedEntityKind(rawValue: kindRaw)
        else { return nil }

        return DeletedEntity(id: id, name: name, kind: kind)
    }

    /// Encodes a domain DeletedEntity into a Firestore-compatible dictionary.
    /// - Parameter entity: The entity to encode.
    /// - Returns: A dictionary representation of the entity.
    private func encode(_ entity: DeletedEntity) -> [String: Any] {
        [
            "id": entity.id.uuidString,
            "name": entity.name,
            "kind": entity.kind.rawValue
        ]
    }
}
