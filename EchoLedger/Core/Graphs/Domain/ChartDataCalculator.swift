//
//  ChartDataCalculator.swift
//  EchoLedger
//
//  Created by Julien Cotte on 12/06/2026.
//

import Foundation

/// Pure, stateless calculations that turn raw transactions into chart-ready data.
/// No I/O and no dependencies — fully unit-testable. The caller decides which
/// transactions to pass in (e.g. only effective ones, see `Transaction.isEffective`).
enum ChartDataCalculator {

    // MARK: Per-account balances

    /// Each account's balance, summed from its transaction splits
    /// (income adds, expense subtracts). Sorted by balance descending.
    static func balancePerAccount(_ transactions: [Transaction],
                                  accounts: [Account]) -> [AccountBalance] {
        let ids = Set(accounts.map(\.id))
        var totals: [UUID: Double] = [:]
        for transaction in transactions {
            for split in transaction.splits where ids.contains(split.accountId) {
                totals[split.accountId, default: 0] += transaction.isExpense ? -split.amount : split.amount
            }
        }
        return accounts
            .map { AccountBalance(account: $0, balance: totals[$0.id] ?? 0) }
            .sorted { $0.balance > $1.balance }
    }

    // MARK: Monthly income / expense

    /// Income and expense totals for each of the 12 months of `year` (reportable
    /// transactions only). Months without data are returned with zero values, so the
    /// chart always spans the full year. `accountId == nil` aggregates all accounts.
    static func monthlyFlows(_ transactions: [Transaction],
                             accountId: UUID? = nil,
                             year: Int = Calendar.current.component(.year, from: Date())) -> [MonthlyFlow] {
        let calendar = Calendar.current
        var income: [Date: Double] = [:]
        var expense: [Date: Double] = [:]
        for transaction in transactions where transaction.category.isReportable {
            let value = amount(of: transaction, for: accountId)
            guard value > 0 else { continue }
            let month = calendar.startOfMonth(for: transaction.date)
            if transaction.isExpense {
                expense[month, default: 0] += value
            } else {
                income[month, default: 0] += value
            }
        }
        return calendar.months(ofYear: year).map { month in
            MonthlyFlow(month: month, income: income[month] ?? 0, expense: expense[month] ?? 0)
        }
    }

    // MARK: Running balance

    /// Cumulative balance over time, one point per day that has activity.
    /// Includes every transaction (initial balances set the starting point).
    /// `accountId == nil` aggregates all accounts.
    static func runningBalance(_ transactions: [Transaction],
                               accountId: UUID? = nil) -> [BalancePoint] {
        let calendar = Calendar.current
        var running: Double = 0
        var balanceByDay: [Date: Double] = [:]
        var dayOrder: [Date] = []
        for transaction in transactions.sorted(by: { $0.date < $1.date }) {
            let value = amount(of: transaction, for: accountId)
            running += transaction.isExpense ? -value : value
            let day = calendar.startOfDay(for: transaction.date)
            if balanceByDay[day] == nil { dayOrder.append(day) }
            balanceByDay[day] = running
        }
        return dayOrder.map { BalancePoint(date: $0, balance: balanceByDay[$0] ?? 0) }
    }

    // MARK: Category breakdown

    /// Totals per category for one side (expense or income), each with its share.
    /// `accountId == nil` = all accounts; `month == nil` = all-time.
    static func categoryBreakdown(_ transactions: [Transaction],
                                  isExpense: Bool,
                                  accountId: UUID? = nil,
                                  month: Date? = nil) -> [CategorySlice] {
        let calendar = Calendar.current
        let targetMonth = month.map { calendar.startOfMonth(for: $0) }
        var totals: [TransactionCategory: Double] = [:]
        for transaction in transactions
        where transaction.category.isReportable && transaction.isExpense == isExpense {
            if let targetMonth, calendar.startOfMonth(for: transaction.date) != targetMonth { continue }
            let value = amount(of: transaction, for: accountId)
            guard value > 0 else { continue }
            totals[transaction.category, default: 0] += value
        }
        let grandTotal = totals.values.reduce(0, +)
        guard grandTotal > 0 else { return [] }
        return totals
            .map { CategorySlice(category: $0.key, total: $0.value, percentage: $0.value / grandTotal * 100) }
            .sorted { $0.total > $1.total }
    }

    // MARK: Monthly pie breakdown

    /// Expense and income category breakdowns for every month that has reportable data.
    /// Months are returned in chronological order. `accountId == nil` aggregates all accounts.
    /// - Parameters:
    ///   - transactions: Effective transactions to analyse.
    ///   - accountId: Restrict to a single account, or `nil` for all accounts.
    /// - Returns: One `MonthlyPieData` per month that contains at least one reportable transaction.
    static func monthlyPieBreakdown(_ transactions: [Transaction],
                                    accountId: UUID? = nil) -> [MonthlyPieData] {
        let calendar = Calendar.current
        var months: Set<Date> = []
        for transaction in transactions where transaction.category.isReportable {
            let value = amount(of: transaction, for: accountId)
            guard value > 0 else { continue }
            months.insert(calendar.startOfMonth(for: transaction.date))
        }
        return months.sorted().map { month in
            MonthlyPieData(
                month: month,
                expenses: categoryBreakdown(transactions, isExpense: true, accountId: accountId, month: month),
                income: categoryBreakdown(transactions, isExpense: false, accountId: accountId, month: month)
            )
        }
    }

    // MARK: Helpers

    /// Amount of a transaction attributable to a given account.
    /// `accountId == nil` returns the full amount (all accounts).
    private static func amount(of transaction: Transaction, for accountId: UUID?) -> Double {
        guard let accountId else { return transaction.totalAmount }
        return transaction.splits
            .filter { $0.accountId == accountId }
            .reduce(0) { $0 + $1.amount }
    }
}
