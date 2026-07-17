//
//  TransactionListViewSnapshotTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 17/07/2026.
//

import XCTest
import SwiftUI
@testable import EchoLedger

@MainActor
final class TransactionListViewSnapshotTests: XCTestCase {

    /// Verifies the appearance of the transaction list. Sets the ViewModel's state directly instead
    /// of calling coordinator.loadData(), avoiding the SwiftData fetch entirely. Dates are fixed
    /// calendar dates so the date-bucketed sections (Aujourd'hui/Cette semaine/Ce mois) never shift.
    func test_transactionListView_appearance() async throws {
        let container = DIContainer(
            userId: PreviewData.user.id,
            toasty: PreviewData.toasty,
            authStoring: PreviewData.authStoring,
            authSession: PreviewData.authSession,
            networkMonitor: PreviewData.networkMonitor,
            inMemory: true
        )
        let coordinator = AppCoordinator(
            container: container,
            user: PreviewData.user,
            onSignOut: {},
            onSessionUpdated: { _ in }
        )

        coordinator.transactionListViewModel.transactions = fixedDateTransactions
        coordinator.transactionListViewModel.availableAccounts = [
            AccountDisplayItem(account: PreviewData.accountCourant, institutionName: PreviewData.institutionBNP.name),
            AccountDisplayItem(account: PreviewData.accountSwile, institutionName: PreviewData.institutionSwile.name)
        ]
        coordinator.transactionListViewModel.accountNames = [
            PreviewData.accountCourant.id: PreviewData.accountCourant.name,
            PreviewData.accountSwile.id: PreviewData.accountSwile.name
        ]

        let sut = TransactionListView(coordinator: coordinator)
            .environment(container)
            .asViewController()

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TRANSACTION_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TRANSACTION_LIST_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraSmall)),
              named: "TRANSACTION_LIST_light_XS")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark, contentSize: .accessibilityExtraExtraExtraLarge)),
              named: "TRANSACTION_LIST_dark_XXXL")
    }

    // MARK: Helpers

    /// A fixed 2023 date, far enough in the past to always fall outside the "today/this week/this
    /// month" buckets — the section it lands in never changes, unlike a date relative to `Date()`.
    private func fixedDate(day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: day))!
    }

    private var fixedDateTransactions: [EchoLedger.Transaction] {
        let salaire = PreviewData.transactionSalaire
        let restaurant = PreviewData.transactionRestaurant
        let courses = PreviewData.transactionCourses
        return [
            EchoLedger.Transaction(userId: salaire.userId, label: salaire.label, date: fixedDate(day: 1),
                                   totalAmount: salaire.totalAmount, isExpense: salaire.isExpense,
                                   category: salaire.category, splits: salaire.splits),
            EchoLedger.Transaction(userId: restaurant.userId, label: restaurant.label, date: fixedDate(day: 5),
                                   totalAmount: restaurant.totalAmount, isExpense: restaurant.isExpense,
                                   category: restaurant.category, splits: restaurant.splits),
            EchoLedger.Transaction(userId: courses.userId, label: courses.label, date: fixedDate(day: 12),
                                   totalAmount: courses.totalAmount, isExpense: courses.isExpense,
                                   category: courses.category, splits: courses.splits)
        ]
    }
}
