//
//  TransactionCloudStoring.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Firebase-only implementation of TransactionProviding.
/// Delegates all reads and writes directly to TransactionRemoteSource, with no local cache.
final class TransactionCloudStoring: TransactionProviding {

    private let remote: TransactionRemoteSource
    private let userId: UUID

    init(remote: TransactionRemoteSource, userId: UUID) {
        self.remote = remote
        self.userId = userId
    }

    func fetchAll(for userId: UUID) async throws -> [Transaction] {
        try await remote.fetchAll(for: userId)
    }

    func fetch(by id: UUID) async throws -> Transaction {
        try await remote.fetch(by: id, userId: userId)
    }

    func save(_ transaction: Transaction) async throws {
        try await remote.save(transaction, userId: userId)
    }

    func update(_ transaction: Transaction) async throws {
        try await remote.update(transaction, userId: userId)
    }

    func delete(by id: UUID) async throws {
        try await remote.delete(id: id, userId: userId)
    }
}
