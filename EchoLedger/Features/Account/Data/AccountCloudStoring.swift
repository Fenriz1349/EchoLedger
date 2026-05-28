//
//  AccountCloudStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Firebase-only implementation of AccountProviding.
/// Delegates all reads and writes directly to AccountRemoteSource, with no local cache.
final class AccountCloudStoring: AccountProviding {

    private let remote: AccountRemoteSource
    private let userId: UUID

    init(remote: AccountRemoteSource, userId: UUID) {
        self.remote = remote
        self.userId = userId
    }

    func fetchAll(for institutionId: UUID) async throws -> [Account] {
        try await remote.fetchAll(for: institutionId, userId: userId)
    }

    func fetchAllActive(for institutionId: UUID) async throws -> [Account] {
        try await remote.fetchAllActive(for: institutionId, userId: userId)
    }

    func fetchAllArchived(for institutionId: UUID) async throws -> [Account] {
        try await remote.fetchAllArchived(for: institutionId, userId: userId)
    }

    func fetch(by id: UUID) async throws -> Account {
        try await remote.fetch(by: id, userId: userId)
    }

    func save(_ account: Account) async throws {
        try await remote.save(account, userId: userId)
    }

    func update(_ account: Account) async throws {
        try await remote.update(account, userId: userId)
    }
}
