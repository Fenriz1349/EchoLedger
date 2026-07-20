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
    /// True if the month has any income or expense (used to skip the net line on empty months).
    var hasData: Bool { income > 0 || expense > 0 }
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

/// An account paired with its computed balance. Feeds the per-account bar chart.
struct AccountBalance: Identifiable {
    let account: Account
    let balance: Double
    var id: UUID { account.id }
}

/// Expense and income category breakdowns for a single month. Feeds the pie carousel.
struct MonthlyPieData: Identifiable {
    /// First day of the month this data represents.
    let month: Date
    let expenses: [CategorySlice]
    let income: [CategorySlice]
    var id: Date { month }
}
