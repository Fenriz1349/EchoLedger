//
//  DeletedEntityDouble.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 29/07/2026.
//

import Foundation
@testable import EchoLedger

/// In-memory mock implementation of DeletedEntityProviding.
/// Used exclusively in unit tests to isolate UseCases from persistence layers.
final class DeletedEntityDouble: DeletedEntityProviding {

    // MARK: In-Memory Store
    private var store: [DeletedEntity] = []

    // MARK: Error Simulation
    /// Set this to force any method to throw a specific error.
    var errorToThrow: Error?

    /// Appends the entity to the in-memory store.
    func save(_ entity: DeletedEntity) async throws {
        if let error = errorToThrow { throw error }
        store.append(entity)
    }

    /// Returns the first entity in the store matching the given id, or nil.
    func fetch(by id: UUID) async throws -> DeletedEntity? {
        if let error = errorToThrow { throw error }
        return store.first { $0.id == id }
    }

    /// Removes every entity from the in-memory store.
    func purge() async throws {
        if let error = errorToThrow { throw error }
        store.removeAll()
    }
}
