//
//  TransactionRepositoryDouble.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 11/03/2026.
//

import Foundation
@testable import EchoLedger

// MARK: - TransactionRepositoryDouble
/// In-memory mock implementation of TransactionRepositoryProtocol.
/// Used exclusively in unit tests to isolate UseCases from persistence layers.
final class TransactionRepositoryDouble: TransactionRepositoryProtocol {

    // MARK: In-Memory Store
    private var store: [Transaction] = []

    // MARK: Spy Properties
    /// Tracks whether save(_:) was called. Useful for asserting side effects.
    var didCallSave = false

    /// Tracks whether update(_:) was called.
    var didCallUpdate = false

    /// Tracks whether delete(by:) was called.
    var didCallDelete = false

    // MARK: Error Simulation
    /// Set this to force any method to throw a specific error.
    var errorToThrow: Error?

    // MARK: TransactionRepositoryProtocol

    /// Returns all transactions in the store associated with the given account.
    func fetchAll(for accountId: UUID) async throws -> [Transaction] {
        if let error = errorToThrow { throw error }
        return store.filter { transaction in
            transaction.splits.contains { $0.accountId == accountId }
        }
    }

    /// Returns the first transaction in the store matching the given id.
    func fetch(by id: UUID) async throws -> Transaction {
        if let error = errorToThrow { throw error }
        guard let transaction = store.first(where: { $0.id == id }) else {
            throw TransactionError.notFound
        }
        return transaction
    }

    /// Appends the transaction to the in-memory store.
    func save(_ transaction: Transaction) async throws {
        if let error = errorToThrow { throw error }
        didCallSave = true
        store.append(transaction)
    }

    /// Replaces the existing transaction in the store with the updated one.
    func update(_ transaction: Transaction) async throws {
        if let error = errorToThrow { throw error }
        didCallUpdate = true
        guard let index = store.firstIndex(where: { $0.id == transaction.id }) else {
            throw TransactionError.notFound
        }
        store[index] = transaction
    }

    /// Removes the transaction matching the given id from the store.
    func delete(by id: UUID) async throws {
        if let error = errorToThrow { throw error }
        didCallDelete = true
        guard store.contains(where: { $0.id == id }) else {
            throw TransactionError.notFound
        }
        store.removeAll { $0.id == id }
    }
}
