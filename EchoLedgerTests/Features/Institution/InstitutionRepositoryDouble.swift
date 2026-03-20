//
//  InstitutionRepositoryDouble.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import Foundation
@testable import EchoLedger

// MARK: - InstitutionRepositoryDouble

/// In-memory mock implementation of InstitutionRepositoryProtocol.
/// Used exclusively in unit tests to isolate UseCases from persistence layers.
final class InstitutionRepositoryDouble: InstitutionRepositoryProtocol {

    // MARK: In-Memory Store
    private var store: [Institution] = []

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

    // MARK: InstitutionRepositoryProtocol

    /// Returns all institutions in the store belonging to the given user.
    func fetchAll(for userId: UUID) async throws -> [Institution] {
        if let error = errorToThrow { throw error }
        return store.filter { $0.userId == userId }
    }

    /// Returns the first institution in the store matching the given id.
    func fetch(by id: UUID) async throws -> Institution {
        if let error = errorToThrow { throw error }
        guard let institution = store.first(where: { $0.id == id }) else {
            throw InstitutionError.notFound
        }
        return institution
    }

    /// Appends the institution to the in-memory store.
    func save(_ institution: Institution) async throws {
        if let error = errorToThrow { throw error }
        didCallSave = true
        store.append(institution)
    }

    /// Replaces the existing institution in the store with the updated one.
    func update(_ institution: Institution) async throws {
        if let error = errorToThrow { throw error }
        didCallUpdate = true
        guard let index = store.firstIndex(where: { $0.id == institution.id }) else {
            throw InstitutionError.notFound
        }
        store[index] = institution
    }

    /// Removes the institution matching the given id from the store.
    func delete(by id: UUID) async throws {
        if let error = errorToThrow { throw error }
        didCallDelete = true
        guard store.contains(where: { $0.id == id }) else {
            throw InstitutionError.notFound
        }
        store.removeAll { $0.id == id }
    }
}
