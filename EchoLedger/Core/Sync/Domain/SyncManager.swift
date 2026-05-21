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
    /// - Local-only record, updatedAt > pivot (or no pivot) → push to remote
    /// - Local-only record, updatedAt ≤ pivot → deleted on remote → delete locally
    /// - Remote-only record, updatedAt > pivot (or no pivot) → pull to local
    /// - Remote-only record, updatedAt ≤ pivot → deleted locally → delete on remote
    /// - Both sides → most recent updatedAt wins
    /// - Accounts are never hard-deleted (archived instead), so delete logic is skipped for them.
    /// No-ops if a sync is already in progress. Cancels after 15 seconds.
    func sync() async {
        guard status != .syncing else { return }
        status = .syncing
        let pivot = lastSyncDate

        let uid = userId
        let instRemote = institutionRemote
        let accRemote = accountRemote
        let txRemote = transactionRemote
        let instLocal = institutionLocal
        let accLocal = accountLocal
        let txLocal = transactionLocal

        let workTask = Task {
            // MARK: 1 — Fetch remote
            let remoteInstitutions = try await instRemote.fetchAll(for: uid)
            let remoteAccounts     = try await accRemote.fetchAll(for: uid)
            let remoteTransactions = try await txRemote.fetchAll(for: uid)

            let remoteInstMap  = Dictionary(uniqueKeysWithValues: remoteInstitutions.map { ($0.id, $0) })
            let remoteAccMap   = Dictionary(uniqueKeysWithValues: remoteAccounts.map { ($0.id, $0) })
            let remoteTransMap = Dictionary(uniqueKeysWithValues: remoteTransactions.map { ($0.id, $0) })

            // MARK: 2 — Fetch local
            let localInstitutions = (try? instLocal.fetchAll(for: uid)) ?? []
            var localAccounts: [Account] = []
            for inst in localInstitutions {
                localAccounts += (try? accLocal.fetchAll(for: inst.id)) ?? []
            }
            let localTransactions = (try? txLocal.fetchAll(for: uid)) ?? []

            // MARK: 3 — Resolve local records
            for local in localInstitutions {
                if let remote = remoteInstMap[local.id] {
                    if SyncManager.localWins(local.updatedAt, remote.updatedAt) {
                        try await instRemote.update(local, userId: uid)
                    } else {
                        try instLocal.upsert(remote)
                    }
                } else if let pivot, let updAt = local.updatedAt, updAt <= pivot {
                    try? instLocal.delete(by: local.id)
                } else {
                    try await instRemote.save(local, userId: uid)
                }
            }

            for local in localAccounts {
                if let remote = remoteAccMap[local.id] {
                    if SyncManager.localWins(local.updatedAt, remote.updatedAt) {
                        try await accRemote.update(local, userId: uid)
                    } else {
                        try accLocal.upsert(remote)
                    }
                } else {
                    try await accRemote.save(local, userId: uid)
                }
            }

            for local in localTransactions {
                if let remote = remoteTransMap[local.id] {
                    if SyncManager.localWins(local.updatedAt, remote.updatedAt) {
                        try await txRemote.update(local, userId: uid)
                    } else {
                        try txLocal.upsert(remote)
                    }
                } else if let pivot, let updAt = local.updatedAt, updAt <= pivot {
                    try? txLocal.delete(by: local.id)
                } else {
                    try await txRemote.save(local, userId: uid)
                }
            }

            // MARK: 4 — Resolve remote-only records
            let localInstIds  = Set(localInstitutions.map(\.id))
            let localAccIds   = Set(localAccounts.map(\.id))
            let localTransIds = Set(localTransactions.map(\.id))

            for remote in remoteInstitutions where !localInstIds.contains(remote.id) {
                if let pivot, let updAt = remote.updatedAt, updAt <= pivot {
                    try await instRemote.delete(id: remote.id, userId: uid)
                } else {
                    try instLocal.upsert(remote)
                }
            }

            for remote in remoteAccounts where !localAccIds.contains(remote.id) {
                try accLocal.upsert(remote)
            }

            for remote in remoteTransactions where !localTransIds.contains(remote.id) {
                if let pivot, let updAt = remote.updatedAt, updAt <= pivot {
                    try await txRemote.delete(id: remote.id, userId: uid)
                } else {
                    try txLocal.upsert(remote)
                }
            }
        }

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

    /// Returns true if the local version should overwrite the remote version.
    /// Local wins when its updatedAt is strictly more recent.
    /// If either side is nil (legacy record), remote wins by default.
    private nonisolated static func localWins(_ local: Date?, _ remote: Date?) -> Bool {
        guard let local, let remote else { return false }
        return local > remote
    }
}
