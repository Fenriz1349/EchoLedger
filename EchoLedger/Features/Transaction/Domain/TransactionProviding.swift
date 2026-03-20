//
//  TransactionProviding.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Defines the contract for transaction persistence.
/// The Domain layer depends only on this protocol — it has no knowledge of CoreData or Firebase.
/// Conforming types live in the Data layer.
protocol TransactionProviding {

    /// Fetches all transactions associated with a given account.
    /// - Parameter userId: The identifier of the user.
    /// - Returns: An array of transactions, ordered by date descending.
    func fetchAll(for userId: UUID) async throws -> [Transaction]

    /// Fetches a single transaction by its identifier.
    /// - Parameter id: The unique identifier of the transaction.
    /// - Returns: The matching transaction.
    func fetch(by id: UUID) async throws -> Transaction

    /// Persists a new transaction along with its splits.
    /// - Parameter transaction: The transaction to save.
    func save(_ transaction: Transaction) async throws

    /// Updates an existing transaction and its splits.
    /// - Parameter transaction: The transaction with updated values.
    func update(_ transaction: Transaction) async throws

    /// Deletes a transaction and all its associated splits.
    /// - Parameter id: The unique identifier of the transaction to delete.
    func delete(by id: UUID) async throws
}
