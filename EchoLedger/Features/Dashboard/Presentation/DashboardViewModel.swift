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
@MainActor
@Observable
final class DashboardViewModel {

    // MARK: State

    var totalBalance: Double = 0
    var accountBalances: [(account: Account, balance: Double)] = []
    var expenseChartData: [(category: TransactionCategory, total: Double)] = []
    var incomeChartData: [(category: TransactionCategory, total: Double)] = []
    var isLoading = false

    // MARK: Dependencies

    private let toasty: ToastyManager
    private let getInstitutions: GetInstitutions
    private let getAccounts: GetAccounts
    private let getTransactions: GetTransactions
    private let userId: UUID

    // MARK: Init

    /// - Parameters:
    ///   - toasty: Toaster to display messages to the user.
    ///   - getInstitutions: UseCase for fetching all institutions.
    ///   - getAccounts: UseCase for fetching accounts per institution.
    ///   - getTransactions: UseCase for fetching all transactions.
    ///   - userId: The identifier of the current user.
    init(
        toasty: ToastyManager,
        getInstitutions: GetInstitutions,
        getAccounts: GetAccounts,
        getTransactions: GetTransactions,
        userId: UUID
    ) {
        self.toasty = toasty
        self.getInstitutions = getInstitutions
        self.getAccounts = getAccounts
        self.getTransactions = getTransactions
        self.userId = userId
    }

    // MARK: Actions

    /// Loads all active accounts, computes balances from transactions in a single fetch,
    /// then builds chart data for expenses and income.
    func load() async {
        isLoading = true
        do {
            let institutions = try await getInstitutions.execute(for: userId)
            var activeAccounts: [Account] = []
            for institution in institutions {
                let accounts = try await getAccounts.execute(for: institution.id, filter: .active)
                activeAccounts.append(contentsOf: accounts)
            }

            let transactions = try await getTransactions.execute(for: userId)
            let balanceMap = computeBalances(from: transactions, accounts: activeAccounts)

            accountBalances = activeAccounts
                .map { (account: $0, balance: balanceMap[$0.id] ?? 0) }
                .sorted { $0.balance > $1.balance }

            totalBalance = accountBalances.map(\.balance).reduce(0, +)
            expenseChartData = chartData(from: transactions.filter { $0.isExpense })
            incomeChartData = chartData(from: transactions.filter { !$0.isExpense })
        } catch {
            toasty.showError(error)
        }
        isLoading = false
    }

    // MARK: Helpers

    /// Computes each account's balance from transactions, without an extra network call per account.
    private func computeBalances(
        from transactions: [Transaction],
        accounts: [Account]
    ) -> [UUID: Double] {
        let accountIds = Set(accounts.map(\.id))
        var balanceMap: [UUID: Double] = [:]
        for transaction in transactions {
            for split in transaction.splits where accountIds.contains(split.accountId) {
                let delta = transaction.isExpense ? -split.amount : split.amount
                balanceMap[split.accountId, default: 0] += delta
            }
        }
        return balanceMap
    }

    /// Groups transactions by category and sums amounts, sorted descending by total.
    private func chartData(
        from transactions: [Transaction]
    ) -> [(category: TransactionCategory, total: Double)] {
        var totals: [TransactionCategory: Double] = [:]
        for transaction in transactions {
            totals[transaction.category, default: 0] += transaction.totalAmount
        }
        return totals
            .map { (category: $0.key, total: $0.value) }
            .filter { $0.total > 0 }
            .sorted { $0.total > $1.total }
    }
}
