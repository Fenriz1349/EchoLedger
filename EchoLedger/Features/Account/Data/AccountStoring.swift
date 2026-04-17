//
//  AccountStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Concrete implementation of AccountProviding.
/// Orchestrates local and remote persistence for the Account feature.
final class AccountStoring: AccountProviding {

    private let local: AccountLocalSource
    private let remote: AccountRemoteSource
    private let userId: UUID

    /// - Parameters:
    ///   - local: The local SwiftData data source.
    ///   - remote: The remote Firestore data source.
    ///   - userId: The identifier of the current user.
    init(local: AccountLocalSource, remote: AccountRemoteSource, userId: UUID) {
        self.local = local
        self.remote = remote
        self.userId = userId
    }

    /// Fetches all accounts for a given institution from local storage.
    func fetchAll(for institutionId: UUID) async throws -> [Account] {
//        try local.fetchAll(for: institutionId)
        try await remote.fetchAll(for: institutionId, userId: userId)
    }

    /// Fetches all active accounts for a given institution from local storage.
    func fetchAllActive(for institutionId: UUID) async throws -> [Account] {
//        try local.fetchAllActive(for: institutionId)
        try await remote.fetchAllActive(for: institutionId, userId: userId)
    }

    /// Fetches all archived accounts for a given institution from local storage.
    func fetchAllArchived(for institutionId: UUID) async throws -> [Account] {
//        try local.fetchAllArchived(for: institutionId)
        try await remote.fetchAllArchived(for: institutionId, userId: userId)
    }

    /// Fetches a single account by id from local storage.
    func fetch(by id: UUID) async throws -> Account {
//        try local.fetch(by: id
        try await remote.fetch(by: id, userId: userId)
    }

    /// Persists a new account to local storage, then attempts a remote save.
    /// - Parameter account: The account to save.
    /// - Throws: A local persistence error if the local save fails.
    func save(_ account: Account) async throws {
//        try local.save(account)
        try await remote.save(account, userId: userId)
    }

    /// Updates an existing account in local storage, then attempts a remote update.
    /// - Parameter account: The account with updated values.
    /// - Throws: A local persistence error if the local update fails.
    func update(_ account: Account) async throws {
//        try local.update(account)
        try await remote.update(account, userId: userId)
    }
}
