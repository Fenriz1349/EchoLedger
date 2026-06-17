//
//  RefreshFromRemote.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/06/2026.
//

import Foundation

/// Refreshes every injected data source from the remote backend, in parallel.
///
/// The use case knows nothing about individual collections: it simply runs all
/// the `RemoteRefreshable` it was given. Adding a new feature (e.g. budgets) means
/// conforming its storing to `RemoteRefreshable` and adding it to the injected
/// array in the DI container — this use case never changes.
final class RefreshFromRemote {

    private let refreshables: [RemoteRefreshable]

    /// - Parameter refreshables: The data sources to refresh. Empty on targets
    ///   without a remote backend, where `execute()` is a no-op.
    init(refreshables: [RemoteRefreshable]) {
        self.refreshables = refreshables
    }

    /// Refreshes all data sources concurrently, returning once every one has
    /// completed. Throws if any refresh fails.
    func execute() async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for refreshable in refreshables {
                group.addTask { try await refreshable.refreshFromRemote() }
            }
            try await group.waitForAll()
        }
    }
}
