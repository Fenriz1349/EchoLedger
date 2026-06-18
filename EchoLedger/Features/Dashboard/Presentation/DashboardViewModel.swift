//
//  DashboardViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 21/05/2026.
//

import Foundation
import Toasty

/// Manages the dashboard screen: triggers data loading and owns the GraphsViewModel.
/// Chart state and navigation live in `graphsViewModel`; errors are surfaced via toasty.
@MainActor
@Observable
final class DashboardViewModel {

    // MARK: Dependencies

    private let toasty: ToastyManager
    private let refreshFromRemote: RefreshFromRemote
    let graphsViewModel: GraphsViewModel

    /// True only during an explicit user-triggered refresh (pull-to-refresh or refresh button).
    /// Drives the branded overlay; navigation reads stay silent since the data is already present.
    private(set) var isRefreshing = false

    // MARK: Init

    /// - Parameters:
    ///   - toasty: Toaster to display error messages to the user.
    ///   - refreshFromRemote: UseCase warming the remote data before a user-triggered reload.
    ///   - graphsViewModel: Child VM owning all chart state for the global scope.
    init(toasty: ToastyManager, refreshFromRemote: RefreshFromRemote, graphsViewModel: GraphsViewModel) {
        self.toasty = toasty
        self.refreshFromRemote = refreshFromRemote
        self.graphsViewModel = graphsViewModel
    }

    // MARK: Actions

    /// Loads every chart dataset for the whole portfolio in one pass.
    func load() async {
        do {
            try await graphsViewModel.load(scope: .global)
        } catch {
            toasty.showError(error)
        }
    }

    /// Pulls fresh data from the remote backend, then reloads the charts from the warmed cache.
    /// Triggered by an explicit user action (pull-to-refresh or the refresh button). A failed
    /// remote pull surfaces a toast but still reloads whatever the cache holds.
    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }
        do {
            try await refreshFromRemote.execute()
        } catch {
            toasty.showError(error)
        }
        await load()
    }
}
