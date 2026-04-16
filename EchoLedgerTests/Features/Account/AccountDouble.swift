//
//  AccountDouble.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/03/2026.
//

import Foundation
@testable import EchoLedger

/// In-memory mock implementation of AccountProviding.
/// Used exclusively in unit tests to isolate UseCases from persistence layers.
final class AccountDouble: AccountProviding {

    // MARK: In-Memory Store
    private var store: [Account] = []

    // MARK: Spy Properties
    /// Tracks whether save(_:) was called.
    var didCallSave = false

    /// Tracks whether update(_:) was called.
    var didCallUpdate = false

    /// Tracks whether delete(by:) was called.
    var didCallDelete = false

    // MARK: Error Simulation
    /// Set this to force any method to throw a specific error.
    var errorToThrow: Error?

    // MARK: AccountProviding

    /// Returns all accounts in the store belonging to the given institution.
    func fetchAll(for institutionId: UUID) async throws -> [Account] {
        if let error = errorToThrow { throw error }
        return store.filter { $0.institutionId == institutionId }
    }

    /// Returns all non-archived accounts in the store belonging to the given institution.
    func fetchAllActive(for institutionId: UUID) async throws -> [Account] {
        if let error = errorToThrow { throw error }
        return store.filter { $0.institutionId == institutionId && !$0.isArchived }
    }

    /// Returns all archived accounts in the store belonging to the given institution.
    func fetchAllArchived(for institutionId: UUID) async throws -> [Account] {
        if let error = errorToThrow { throw error }
        return store.filter { $0.institutionId == institutionId && $0.isArchived }
    }

    /// Returns the first account in the store matching the given id.
    func fetch(by id: UUID) async throws -> Account {
        if let error = errorToThrow { throw error }
        guard let account = store.first(where: { $0.id == id }) else {
            throw AccountError.notFound
        }
        return account
    }

    /// Appends the account to the in-memory store.
    func save(_ account: Account) async throws {
        if let error = errorToThrow { throw error }
        didCallSave = true
        store.append(account)
    }

    /// Replaces the existing account in the store with the updated one.
    func update(_ account: Account) async throws {
        if let error = errorToThrow { throw error }
        didCallUpdate = true
        guard let index = store.firstIndex(where: { $0.id == account.id }) else {
            throw AccountError.notFound
        }
        store[index] = account
    }

    /// Removes the account matching the given id from the store.
    func delete(by id: UUID) async throws {
        if let error = errorToThrow { throw error }
        didCallDelete = true
        guard store.contains(where: { $0.id == id }) else {
            throw AccountError.notFound
        }
        store.removeAll { $0.id == id }
    }
}
