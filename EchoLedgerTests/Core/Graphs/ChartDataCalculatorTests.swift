//
//  ChartDataCalculatorTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class ChartDataCalculatorTests: XCTestCase {

    private let userId = UUID()
    private let accountId = UUID()

    // MARK: Helpers
    private func transaction(amount: Double,
                             isExpense: Bool,
                             category: TransactionCategory = .other,
                             accountId: UUID? = nil,
                             date: Date = Date()) -> Transaction {
        Transaction(userId: userId,
                    label: "T",
                    date: date,
                    totalAmount: amount,
                    isExpense: isExpense,
                    category: category,
                    splits: [TransactionSplit(accountId: accountId ?? self.accountId, amount: amount)])
    }

    private func date(year: Int, month: Int, day: Int = 15) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }

    // MARK: balancePerAccount
    /// Verifies that income adds and expense subtracts per account.
    func test_balancePerAccount_sumsIncomeMinusExpense() {
        let account = TestData.account(id: accountId)
        let transactions = [
            transaction(amount: 100, isExpense: false),
            transaction(amount: 30, isExpense: true)
        ]
        let result = ChartDataCalculator.balancePerAccount(transactions, accounts: [account])
        XCTAssertEqual(result.first?.balance, 70)
    }

    /// Verifies that accounts are sorted by balance descending.
    func test_balancePerAccount_sortedByBalanceDescending() {
        let small = UUID()
        let big = UUID()
        let accounts = [TestData.account(id: small), TestData.account(id: big)]
        let transactions = [
            transaction(amount: 10, isExpense: false, accountId: small),
            transaction(amount: 100, isExpense: false, accountId: big)
        ]
        let result = ChartDataCalculator.balancePerAccount(transactions, accounts: accounts)
        XCTAssertEqual(result.map { $0.account.id }, [big, small])
    }

    /// Verifies that an account with no transactions has a zero balance.
    func test_balancePerAccount_noTransactions_isZero() {
        let account = TestData.account(id: accountId)
        let result = ChartDataCalculator.balancePerAccount([], accounts: [account])
        XCTAssertEqual(result.first?.balance, 0)
    }

    // MARK: monthlyFlows
    /// Verifies that the result always spans the full 12 months.
    func test_monthlyFlows_returnsTwelveMonths() {
        let result = ChartDataCalculator.monthlyFlows([], year: 2026)
        XCTAssertEqual(result.count, 12)
    }

    /// Verifies that income and expense land in the correct month.
    func test_monthlyFlows_placesValuesInCorrectMonth() {
        let january = date(year: 2026, month: 1)
        let transactions = [
            transaction(amount: 200, isExpense: false, category: .salary, date: january),
            transaction(amount: 50, isExpense: true, category: .restaurant, date: january)
        ]
        let result = ChartDataCalculator.monthlyFlows(transactions, year: 2026)
        let flow = result.first { Calendar.current.component(.month, from: $0.month) == 1 }
        XCTAssertEqual(flow?.income, 200)
        XCTAssertEqual(flow?.expense, 50)
    }

    /// Verifies that non-reportable categories (e.g. transfer) are excluded.
    func test_monthlyFlows_excludesNonReportableCategories() {
        let transactions = [
            transaction(amount: 100, isExpense: true, category: .transfer, date: date(year: 2026, month: 1))
        ]
        let result = ChartDataCalculator.monthlyFlows(transactions, year: 2026)
        XCTAssertTrue(result.allSatisfy { $0.income == 0 && $0.expense == 0 })
    }

    // MARK: categoryBreakdown
    /// Verifies totals, percentages and descending order per category.
    func test_categoryBreakdown_computesTotalsAndPercentages() {
        let transactions = [
            transaction(amount: 75, isExpense: true, category: .restaurant),
            transaction(amount: 25, isExpense: true, category: .shopping)
        ]
        let result = ChartDataCalculator.categoryBreakdown(transactions, isExpense: true)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.first?.category, .restaurant)
        XCTAssertEqual(result.first?.total, 75)
        XCTAssertEqual(result.first?.percentage, 75)
    }

    /// Verifies that the opposite side (income vs expense) is excluded.
    func test_categoryBreakdown_excludesOtherSide() {
        let transactions = [
            transaction(amount: 50, isExpense: true, category: .restaurant),
            transaction(amount: 200, isExpense: false, category: .salary)
        ]
        let result = ChartDataCalculator.categoryBreakdown(transactions, isExpense: true)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.category, .restaurant)
    }

    // MARK: monthlyPieBreakdown
    /// Verifies that one entry is returned per month that has reportable data.
    func test_monthlyPieBreakdown_oneEntryPerMonthWithData() {
        let transactions = [
            transaction(amount: 50, isExpense: true, category: .restaurant, date: date(year: 2026, month: 1)),
            transaction(amount: 80, isExpense: false, category: .salary, date: date(year: 2026, month: 2))
        ]
        let result = ChartDataCalculator.monthlyPieBreakdown(transactions)
        XCTAssertEqual(result.count, 2)
    }
}
