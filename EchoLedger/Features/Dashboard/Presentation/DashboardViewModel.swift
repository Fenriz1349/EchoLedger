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
    let graphsViewModel: GraphsViewModel

    // MARK: Init

    /// - Parameters:
    ///   - toasty: Toaster to display error messages to the user.
    ///   - graphsViewModel: Child VM owning all chart state for the global scope.
    init(toasty: ToastyManager, graphsViewModel: GraphsViewModel) {
        self.toasty = toasty
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
}
