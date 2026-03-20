//
//  AccountStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Concrete implementation of AccountProviding.
final class AccountStoring: AccountProviding {

    // MARK: Dependencies
    private let local: AccountLocalSource

    // MARK: Init
    /// - Parameter local: The local SwiftData data source.
    init(local: AccountLocalSource) {
        self.local = local
    }

    // MARK: AccountProviding

    /// Fetches all accounts for a given institution from local storage.
    func fetchAll(for institutionId: UUID) async throws -> [Account] {
        try local.fetchAll(for: institutionId)
    }

    /// Fetches a single account by id from local storage.
    func fetch(by id: UUID) async throws -> Account {
        try local.fetch(by: id)
    }

    /// Persists a new account to local storage.
    func save(_ account: Account) async throws {
        try local.save(account)
    }

    /// Updates an existing account in local storage.
    func update(_ account: Account) async throws {
        try local.update(account)
    }

    /// Deletes an account from local storage.
    func delete(by id: UUID) async throws {
        try local.delete(by: id)
    }
}
