//
//  DashboardViewModel.swift
//  EchoLedger
//
//  Created by Julien Cotte on 21/05/2026.
//

import Foundation
import Toasty

/// Manages the data displayed on the dashboard:
/// total balance, per-account breakdown, and expense/income chart data.
/// All computation lives in `ChartDataCalculator` behind the `GetChartData` use case.
@MainActor
@Observable
final class DashboardViewModel {

    // MARK: State

    var totalBalance: Double = 0
    var accountBalances: [AccountBalance] = []
    var expenseTotals: [CategorySlice] = []
    var incomeTotals: [CategorySlice] = []
    var monthlyFlows: [MonthlyFlow] = []
    var isLoading = false

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
        } catch {
            toasty.showError(error)
        }
        isLoading = false
    }
}
