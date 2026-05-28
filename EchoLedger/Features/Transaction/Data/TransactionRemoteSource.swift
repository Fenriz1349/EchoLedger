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

    // MARK: Read

    /// Fetches all transactions for a given user from Firestore, ordered by date descending.
    func fetchAll(for userId: UUID) async throws -> [Transaction] {
        let snapshot = try await collection(for: userId)
            .order(by: "date", descending: true)
            .getDocuments()
        return snapshot.documents.compactMap { decode($0.data()) }
    }

    /// Fetches a single transaction by its identifier from Firestore.
    func fetch(by id: UUID, userId: UUID) async throws -> Transaction {
        let document = try await collection(for: userId).document(id.uuidString).getDocument()
        guard let data = document.data(), let transaction = decode(data) else {
            throw TransactionError.notFound
        }
        return transaction
    }

    // MARK: Private

    private func decode(_ data: [String: Any]) -> Transaction? {
        guard
            let idString = data["id"] as? String,
            let id = UUID(uuidString: idString),
            let userIdString = data["userId"] as? String,
            let userId = UUID(uuidString: userIdString),
            let label = data["label"] as? String,
            let timestamp = data["date"] as? Timestamp,
            let totalAmount = data["totalAmount"] as? Double,
            let isExpense = data["isExpense"] as? Bool,
            let categoryRaw = data["category"] as? String,
            let category = TransactionCategory(rawValue: categoryRaw),
            let splitsData = data["splits"] as? [[String: Any]]
        else { return nil }

        return Transaction(
            id: id,
            userId: userId,
            label: label,
            date: timestamp.dateValue(),
            totalAmount: totalAmount,
            note: data["note"] as? String,
            isExpense: isExpense,
            category: category,
            splits: splitsData.compactMap { decodeSplit($0) },
            photoURL: data["photoURL"] as? String,
            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue()
        )
    }

    private func decodeSplit(_ data: [String: Any]) -> TransactionSplit? {
        guard
            let idString = data["id"] as? String,
            let id = UUID(uuidString: idString),
            let accountIdString = data["accountId"] as? String,
            let accountId = UUID(uuidString: accountIdString),
            let amount = data["amount"] as? Double
        else { return nil }

        return TransactionSplit(id: id, accountId: accountId, amount: amount)
    }

    // MARK: Private

    /// Encodes a domain Transaction into a Firestore-compatible dictionary.
    /// - Parameter transaction: The transaction to encode.
    /// - Returns: A dictionary representation of the transaction including embedded splits.
    private func encode(_ transaction: Transaction) -> [String: Any] {
        var data: [String: Any] = [
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
        if let photoURL = transaction.photoURL {
            data["photoURL"] = photoURL
        }
        if let updatedAt = transaction.updatedAt {
            data["updatedAt"] = Timestamp(date: updatedAt)
        }
        return data
    }
}
