//
//  ChartModels.swift
//  EchoLedger
//
//  Created by Julien Cotte on 12/06/2026.
//

import Foundation

/// Income and expense totals for a single month.
/// Feeds the monthly bar chart (two bars per month); `net` is overlaid as a line.
struct MonthlyFlow: Identifiable {
    /// First day of the month this flow represents.
    let month: Date
    let income: Double
    let expense: Double
    var net: Double { income - expense }
    var id: Date { month }
}

/// One slice of a category pie chart: a category, its total and its share of the whole.
struct CategorySlice: Identifiable {
    let category: TransactionCategory
    let total: Double
    /// Share of the total, 0...100.
    let percentage: Double
    var id: TransactionCategory { category }
}

/// A single point on the running-balance line: the cumulative balance at a date.
struct BalancePoint: Identifiable {
    let date: Date
    let balance: Double
    var id: Date { date }
}

/// An account paired with its computed balance. Feeds the per-account bar chart.
struct AccountBalance: Identifiable {
    let account: Account
    let balance: Double
    var id: UUID { account.id }
}
