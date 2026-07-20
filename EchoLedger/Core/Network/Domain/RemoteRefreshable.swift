//
//  RemoteRefreshable.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/06/2026.
//

import Foundation

/// A data source able to refresh its own cache from the remote backend.
///
/// Each cloud-backed storing conforms to warm its Firestore cache with a fresh
/// server read. The classic (local) storings don't conform — reload is a no-op
/// for them until the real local↔remote sync arrives.
///
/// This is the seam between *reload* (pull-and-warm, triggered by the user) and
/// *sync* (reconcile local and remote with tombstones). Both targets share the
/// same trigger points; only the injected set of refreshables differs.
protocol RemoteRefreshable {

    /// Pulls the latest data from the remote backend, warming the local cache.
    /// - Throws: A backend error if the remote read fails.
    func refreshFromRemote() async throws
}
