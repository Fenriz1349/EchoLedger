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

    /// Fetches all remote data and upserts it into local storage.
    /// Sets `status` to `.syncing` while running, then `.success` or `.failure` on completion.
    /// No-ops if a sync is already in progress.
    func sync() async {
        guard status != .syncing else { return }
        status = .syncing
        do {
            let institutions = try await institutionRemote.fetchAll(for: userId)
            let accounts = try await accountRemote.fetchAll(for: userId)
            let transactions = try await transactionRemote.fetchAll(for: userId)

            for institution in institutions { try institutionLocal.upsert(institution) }
            for account in accounts { try accountLocal.upsert(account) }
            for transaction in transactions { try transactionLocal.upsert(transaction) }

            SyncMetadata.save()
            lastSyncDate = SyncMetadata.lastSyncDate
            status = .success(lastSyncDate!)
        } catch {
            status = .failure(error.localizedDescription)
        }
    }
}
