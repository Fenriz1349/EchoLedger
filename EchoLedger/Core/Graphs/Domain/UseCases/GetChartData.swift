//
//  GetChartData.swift
//  EchoLedger
//
//  Created by Julien Cotte on 12/06/2026.
//

import Foundation

/// What the chart data covers: the whole portfolio, or a single account.
enum ChartScope: Equatable {
    case global
    case account(UUID)
}

/// All chart datasets for a scope, computed from a single fetch.
struct ChartBundle {
    let totalBalance: Double
    let accountBalances: [AccountBalance]
    let monthlyFlows: [MonthlyFlow]
    let expenseTotals: [CategorySlice]
    let incomeTotals: [CategorySlice]
    let monthlyPieData: [MonthlyPieData]
}

/// Fetches the data the charts need in a single pass, then delegates all
/// computation to `ChartDataCalculator`. Future-dated transactions are excluded
/// (see `Transaction.isEffective`) so scheduled recurrences don't count yet.
final class GetChartData {

    private let getInstitutions: GetInstitutions
    private let getAccounts: GetAccounts
    private let getTransactions: GetTransactions
    private let userId: UUID

    init(getInstitutions: GetInstitutions,
         getAccounts: GetAccounts,
         getTransactions: GetTransactions,
         userId: UUID) {
        self.getInstitutions = getInstitutions
        self.getAccounts = getAccounts
        self.getTransactions = getTransactions
        self.userId = userId
    }

    /// - Parameter scope: `.global` for the whole portfolio, `.account(id)` for one account.
    /// - Returns: A bundle with every chart dataset for that scope.
    func execute(scope: ChartScope = .global) async throws -> ChartBundle {
        // Active accounts across all institutions.
        let institutions = try await getInstitutions.execute(for: userId)
        var activeAccounts: [Account] = []
        for institution in institutions {
            let accounts = try await getAccounts.execute(for: institution.id, filter: .active)
            activeAccounts.append(contentsOf: accounts)
        }

        // Single fetch; only effective (non-future) transactions feed the charts.
        let transactions = try await getTransactions.execute(for: userId)
            .filter { $0.isEffective() }

        // Narrow to a single account when scoped.
        let accountId: UUID?
        let scopedAccounts: [Account]
        switch scope {
        case .global:
            accountId = nil
            scopedAccounts = activeAccounts
        case .account(let id):
            accountId = id
            scopedAccounts = activeAccounts.filter { $0.id == id }
        }

        let balances = ChartDataCalculator.balancePerAccount(transactions, accounts: scopedAccounts)

        return ChartBundle(
            totalBalance: balances.reduce(0) { $0 + $1.balance },
            accountBalances: balances,
            monthlyFlows: ChartDataCalculator.monthlyFlows(transactions, accountId: accountId),
            expenseTotals: ChartDataCalculator.categoryBreakdown(transactions, isExpense: true, accountId: accountId),
            incomeTotals: ChartDataCalculator.categoryBreakdown(transactions, isExpense: false, accountId: accountId),
            monthlyPieData: ChartDataCalculator.monthlyPieBreakdown(transactions, accountId: accountId)
        )
    }
}
