//
//  InstitutionStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Concrete implementation of InstitutionProviding.
final class InstitutionStoring: InstitutionProviding {

    private let local: InstitutionLocalSource

    /// - Parameter local: The local SwiftData data source.
    init(local: InstitutionLocalSource) {
        self.local = local
    }

    /// Fetches all institutions for a given user from local storage.
    func fetchAll(for userId: UUID) async throws -> [Institution] {
        try local.fetchAll(for: userId)
    }

    /// Fetches a single institution by id from local storage.
    func fetch(by id: UUID) async throws -> Institution {
        try local.fetch(by: id)
    }

    /// Persists a new institution to local storage.
    func save(_ institution: Institution) async throws {
        try local.save(institution)
    }

    /// Updates an existing institution in local storage.
    func update(_ institution: Institution) async throws {
        try local.update(institution)
    }

    /// Deletes an institution and its accounts from local storage.
    func delete(by id: UUID) async throws {
        try local.delete(by: id)
    }
}
