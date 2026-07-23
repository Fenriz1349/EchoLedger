//
//  InstitutionDouble.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import Foundation
@testable import EchoLedger

/// In-memory mock implementation of InstitutionProviding.
/// Used exclusively in unit tests to isolate UseCases from persistence layers.
final class InstitutionDouble: InstitutionProviding {

    // MARK: In-Memory Store
    private var store: [Institution] = []

    // MARK: Error Simulation
    /// Set this to force any method to throw a specific error.
    var errorToThrow: Error?

    // MARK: InstitutionProviding

    /// Returns the first institution in the store matching the given id.
    func fetch(by id: UUID) async throws -> Institution {
        if let error = errorToThrow { throw error }
        guard let institution = store.first(where: { $0.id == id }) else {
            throw InstitutionError.notFound
        }
        return institution
    }

    /// Returns all institutions in the store belonging to the given user.
    func fetchAll(for userId: UUID) async throws -> [Institution] {
        if let error = errorToThrow { throw error }
        return store.filter { $0.userId == userId }
    }

    /// Appends the institution to the in-memory store.
    func save(_ institution: Institution) async throws {
        if let error = errorToThrow { throw error }
        store.append(institution)
    }

    /// Replaces the existing institution in the store with the updated one.
    func update(_ institution: Institution) async throws {
        if let error = errorToThrow { throw error }
        guard let index = store.firstIndex(where: { $0.id == institution.id }) else {
            throw InstitutionError.notFound
        }
        store[index] = institution
    }

    /// Marks the matching institution as archived in the store.
    func archive(by id: UUID) async throws {
        if let error = errorToThrow { throw error }
        try setArchived(true, for: id)
    }

    /// Restores the matching institution to active status in the store.
    func unarchive(by id: UUID) async throws {
        if let error = errorToThrow { throw error }
        try setArchived(false, for: id)
    }

    /// Rebuilds the stored institution with a new `isArchived` value (the entity is immutable).
    private func setArchived(_ value: Bool, for id: UUID) throws {
        guard let index = store.firstIndex(where: { $0.id == id }) else {
            throw InstitutionError.notFound
        }
        let current = store[index]
        store[index] = Institution(
            id: current.id,
            userId: current.userId,
            name: current.name,
            category: current.category,
            logoURL: current.logoURL,
            isArchived: value,
            updatedAt: current.updatedAt
        )
    }

    /// Removes the institution matching the given id from the store.
    func delete(by id: UUID) async throws {
        if let error = errorToThrow { throw error }
        guard store.contains(where: { $0.id == id }) else {
            throw InstitutionError.notFound
        }
        store.removeAll { $0.id == id }
    }
}
