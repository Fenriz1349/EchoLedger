//
//  GraphsViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 13/06/2026.
//

import SwiftUI

/// Owns all chart state and carousel navigation for a given scope (global or per-account).
/// Designed to be held by a screen-level ViewModel that handles errors via its own toasty instance.
@MainActor
@Observable
final class GraphsViewModel {

    // MARK: Dependencies

    private let getChartData: GetChartData

    // MARK: Init

    /// - Parameter getChartData: Use case that fetches and computes all chart datasets.
    init(getChartData: GetChartData) {
        self.getChartData = getChartData
    }

    // MARK: State

    var totalBalance: Double = 0
    var accountBalances: [AccountBalance] = []
    var expenseTotals: [CategorySlice] = []
    var incomeTotals: [CategorySlice] = []
    var monthlyFlows: [MonthlyFlow] = []
    var monthlyPieData: [MonthlyPieData] = []
    var selectedPieIndex: Int = 0
    var isLoading = false

    var canGoPreviousPie: Bool { selectedPieIndex > 0 }
    var canGoNextPie: Bool { selectedPieIndex < monthlyPieData.count - 1 }

    // MARK: Carousel navigation

    /// Moves the pie carousel to the previous month if possible.
    func goToPreviousPie() {
        guard canGoPreviousPie else { return }
        withAnimation(.easeInOut(duration: 0.2)) { selectedPieIndex -= 1 }
    }

    /// Moves the pie carousel to the next month if possible.
    func goToNextPie() {
        guard canGoNextPie else { return }
        withAnimation(.easeInOut(duration: 0.2)) { selectedPieIndex += 1 }
    }

    /// Interprets a drag translation as a previous/next navigation gesture.
    /// - Parameter translation: The drag gesture translation.
    func handlePieSwipe(_ translation: CGSize) {
        guard abs(translation.width) > abs(translation.height) else { return }
        if translation.width < -30 { goToNextPie() }
        else if translation.width > 30 { goToPreviousPie() }
    }

    // MARK: Actions

    /// Fetches and applies all chart datasets for the given scope.
    /// Throws so the caller's ViewModel can handle errors with its own toasty instance.
    /// - Parameter scope: `.global` for the whole portfolio, `.account(id)` for one account.
    func load(scope: ChartScope = .global) async throws {
        isLoading = true
        defer { isLoading = false }
        let bundle = try await getChartData.execute(scope: scope)
        totalBalance = bundle.totalBalance
        accountBalances = bundle.accountBalances
        expenseTotals = bundle.expenseTotals
        incomeTotals = bundle.incomeTotals
        monthlyFlows = bundle.monthlyFlows
        monthlyPieData = bundle.monthlyPieData
        let now = Calendar.current.startOfMonth(for: Date())
        selectedPieIndex = bundle.monthlyPieData.lastIndex(where: { $0.month <= now })
            ?? max(bundle.monthlyPieData.count - 1, 0)
    }
}
