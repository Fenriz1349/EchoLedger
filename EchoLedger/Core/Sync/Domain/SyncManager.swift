//
//  SyncManager.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

@MainActor
@Observable
final class SyncManager: SyncManagerProtocol {

    private(set) var status: SyncStatus = .waiting
    private(set) var lastSyncDate: Date? = SyncMetadata.lastSyncDate

    private let userId: UUID
    private let institutionRemote: InstitutionRemoteSource
    private let accountRemote: AccountRemoteSource
    private let transactionRemote: TransactionRemoteSource
    private let institutionLocal: InstitutionLocalSource
    private let accountLocal: AccountLocalSource
    private let transactionLocal: TransactionLocalSource

    init(userId: UUID,
         institutionRemote: InstitutionRemoteSource,
         accountRemote: AccountRemoteSource,
         transactionRemote: TransactionRemoteSource,
         institutionLocal: InstitutionLocalSource,
         accountLocal: AccountLocalSource,
         transactionLocal: TransactionLocalSource) {
        self.userId = userId
        self.institutionRemote = institutionRemote
        self.accountRemote = accountRemote
        self.transactionRemote = transactionRemote
        self.institutionLocal = institutionLocal
        self.accountLocal = accountLocal
        self.transactionLocal = transactionLocal
    }

    /// Bidirectional sync with last-write-wins conflict resolution and lastSyncDate-based delete detection.
    /// No-ops if a sync is already in progress. Cancels after 15 seconds.
    func sync() async {
        guard status != .syncing else { return }
        status = .syncing

        let workTask = Task { try await performSync(pivot: lastSyncDate) }
        let timeoutTask = Task {
            try await Task.sleep(for: .seconds(15))
            workTask.cancel()
        }

        do {
            try await workTask.value
            timeoutTask.cancel()
            SyncMetadata.save()
            lastSyncDate = SyncMetadata.lastSyncDate
            status = .success(lastSyncDate!)
        } catch is CancellationError {
            timeoutTask.cancel()
            status = .failure("Sync expiré après 15 secondes")
        } catch {
            timeoutTask.cancel()
            status = .failure(error.localizedDescription)
        }
    }

    // MARK: - Orchestration

    private func performSync(pivot: Date?) async throws {
        let remoteInstitutions = try await institutionRemote.fetchAll(for: userId)
        let remoteAccounts     = try await accountRemote.fetchAll(for: userId)
        let remoteTransactions = try await transactionRemote.fetchAll(for: userId)

        let localInstitutions  = (try? institutionLocal.fetchAll(for: userId)) ?? []
        let localAccounts      = localInstitutions.flatMap { (try? accountLocal.fetchAll(for: $0.id)) ?? [] }
        let localTransactions  = (try? transactionLocal.fetchAll(for: userId)) ?? []

        let remoteInstMap  = Dictionary(uniqueKeysWithValues: remoteInstitutions.map { ($0.id, $0) })
        let remoteAccMap   = Dictionary(uniqueKeysWithValues: remoteAccounts.map { ($0.id, $0) })
        let remoteTransMap = Dictionary(uniqueKeysWithValues: remoteTransactions.map { ($0.id, $0) })

        try await syncLocalInstitutions(localInstitutions, remoteMap: remoteInstMap, pivot: pivot)
        try await syncLocalAccounts(localAccounts, remoteMap: remoteAccMap)
        try await syncLocalTransactions(localTransactions, remoteMap: remoteTransMap, pivot: pivot)

        let localInstIds  = Set(localInstitutions.map(\.id))
        let localAccIds   = Set(localAccounts.map(\.id))
        let localTransIds = Set(localTransactions.map(\.id))

        try await syncRemoteOnlyInstitutions(remoteInstitutions, localIds: localInstIds, pivot: pivot)
        syncRemoteOnlyAccounts(remoteAccounts, localIds: localAccIds)
        try await syncRemoteOnlyTransactions(remoteTransactions, localIds: localTransIds, pivot: pivot)
    }

    // MARK: - Local → Remote

    private func syncLocalInstitutions(
        _ locals: [Institution],
        remoteMap: [UUID: Institution],
        pivot: Date?
    ) async throws {
        for local in locals {
            if let remote = remoteMap[local.id] {
                if SyncManager.localWins(local.updatedAt, remote.updatedAt) {
                    try await institutionRemote.update(local, userId: userId)
                } else {
                    try institutionLocal.upsert(remote)
                }
            } else {
                // Interim: never delete on local absence (caused data loss).
                // A local-only record is pushed, not deleted. Real deletes will
                // propagate via tombstones (deletedAt) — see sync rework Plan 1.
                try await institutionRemote.save(local, userId: userId)
            }
        }
    }

    private func syncLocalAccounts(
        _ locals: [Account],
        remoteMap: [UUID: Account]
    ) async throws {
        for local in locals {
            if let remote = remoteMap[local.id] {
                if SyncManager.localWins(local.updatedAt, remote.updatedAt) {
                    try await accountRemote.update(local, userId: userId)
                } else {
                    try accountLocal.upsert(remote)
                }
            } else {
                try await accountRemote.save(local, userId: userId)
            }
        }
    }

    private func syncLocalTransactions(
        _ locals: [Transaction],
        remoteMap: [UUID: Transaction],
        pivot: Date?
    ) async throws {
        for local in locals {
            if let remote = remoteMap[local.id] {
                if SyncManager.localWins(local.updatedAt, remote.updatedAt) {
                    try await transactionRemote.update(local, userId: userId)
                } else {
                    try transactionLocal.upsert(remote)
                }
            } else {
                // Interim: never delete on local absence (see syncLocalInstitutions).
                try await transactionRemote.save(local, userId: userId)
            }
        }
    }

    // MARK: - Remote → Local

    private func syncRemoteOnlyInstitutions(
        _ remotes: [Institution],
        localIds: Set<UUID>,
        pivot: Date?
    ) async throws {
        // Interim: pull-only. We no longer delete remote records on local absence
        // (caused data loss). Real deletes will propagate via tombstones — see Plan 1.
        for remote in remotes where !localIds.contains(remote.id) {
            try institutionLocal.upsert(remote)
        }
    }

    /// Accounts are never hard-deleted (archived instead) — just pull missing ones locally.
    private func syncRemoteOnlyAccounts(_ remotes: [Account], localIds: Set<UUID>) {
        for remote in remotes where !localIds.contains(remote.id) {
            try? accountLocal.upsert(remote)
        }
    }

    private func syncRemoteOnlyTransactions(
        _ remotes: [Transaction],
        localIds: Set<UUID>,
        pivot: Date?
    ) async throws {
        // Interim: pull-only (see syncRemoteOnlyInstitutions).
        for remote in remotes where !localIds.contains(remote.id) {
            try transactionLocal.upsert(remote)
        }
    }

    // MARK: - Helpers

    /// Returns true if the local version should overwrite the remote version.
    /// Local wins when its updatedAt is strictly more recent.
    /// If either side is nil (legacy record), remote wins by default.
    private nonisolated static func localWins(_ local: Date?, _ remote: Date?) -> Bool {
        guard let local, let remote else { return false }
        return local > remote
    }
}
