//
//  TransactionRemoteSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation
import FirebaseFirestore

/// Handles all Firestore read and write operations for the Transaction feature.
final class TransactionRemoteSource {

    private lazy var firestore = Firestore.firestore()

    private func collection(for userId: UUID) -> CollectionReference {
        firestore.collection("users").document(userId.uuidString)
            .collection("transactions")
    }

    // MARK: Write

    /// Saves a new transaction and its splits to Firestore.
    /// - Parameters:
    ///   - transaction: The domain Transaction to persist remotely.
    ///   - userId: The identifier of the owning user.
    /// - Throws: A Firestore error if the write fails.
    func save(_ transaction: Transaction, userId: UUID) async throws {
        try await collection(for: userId)
            .document(transaction.id.uuidString)
            .setData(encode(transaction))
    }

    /// Updates an existing transaction and its splits in Firestore.
    /// - Parameters:
    ///   - transaction: The domain Transaction with updated values.
    ///   - userId: The identifier of the owning user.
    /// - Throws: A Firestore error if the write fails.
    func update(_ transaction: Transaction, userId: UUID) async throws {
        try await collection(for: userId)
            .document(transaction.id.uuidString)
            .setData(encode(transaction), merge: true)
    }

    /// Deletes a transaction from Firestore.
    /// - Parameters:
    ///   - id: The identifier of the transaction to delete.
    ///   - userId: The identifier of the owning user.
    /// - Throws: A Firestore error if the write fails.
    func delete(id: UUID, userId: UUID) async throws {
        try await collection(for: userId)
            .document(id.uuidString)
            .delete()
    }

    // MARK: Private

    /// Encodes a domain Transaction into a Firestore-compatible dictionary.
    /// - Parameter transaction: The transaction to encode.
    /// - Returns: A dictionary representation of the transaction including embedded splits.
    private func encode(_ transaction: Transaction) -> [String: Any] {
        [
            "id": transaction.id.uuidString,
            "userId": transaction.userId.uuidString,
            "label": transaction.label,
            "date": Timestamp(date: transaction.date),
            "totalAmount": transaction.totalAmount,
            "note": transaction.note as Any,
            "isExpense": transaction.isExpense,
            "category": transaction.category.rawValue,
            "splits": transaction.splits.map { split in
                [
                    "id": split.id.uuidString,
                    "accountId": split.accountId.uuidString,
                    "amount": split.amount
                ] as [String: Any]
            }
        ]
    }
}
