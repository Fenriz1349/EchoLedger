//
//  DashboardViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 21/05/2026.
//

import SwiftUI
import Toasty

/// Manages the data displayed on the dashboard:
/// total balance, per-account breakdown, and expense/income chart data.
/// All computation lives in `ChartDataCalculator` behind the `GetChartData` use case.
@MainActor
@Observable
final class DashboardViewModel {

    // MARK: Dependencies

    private let toasty: ToastyManager
    private let getChartData: GetChartData

    // MARK: Init

    /// - Parameters:
    ///   - toasty: Toaster to display messages to the user.
    ///   - getChartData: UseCase computing all dashboard chart datasets in a single fetch.
    init(toasty: ToastyManager, getChartData: GetChartData) {
        self.toasty = toasty
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

    /// Loads every chart dataset for the whole portfolio in one pass.
    func load() async {
        isLoading = true
        do {
            let bundle = try await getChartData.execute(scope: .global)
            totalBalance = bundle.totalBalance
            accountBalances = bundle.accountBalances
            expenseTotals = bundle.expenseTotals
            incomeTotals = bundle.incomeTotals
            monthlyFlows = bundle.monthlyFlows
            monthlyPieData = bundle.monthlyPieData
            let now = Calendar.current.startOfMonth(for: Date())
            selectedPieIndex = bundle.monthlyPieData.lastIndex(where: { $0.month <= now })
                ?? max(bundle.monthlyPieData.count - 1, 0)
        } catch {
            toasty.showError(error)
        }
        isLoading = false
    }
}
