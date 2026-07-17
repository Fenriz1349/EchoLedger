//
//  TransactionListViewSnapshotTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 17/07/2026.
//

import XCTest
import SwiftUI
import SwiftData
@testable import EchoLedger

@MainActor
final class TransactionListViewSnapshotTests: XCTestCase {

    /// Verifies the appearance of the transaction list. Uses a dedicated in-memory container seeded
    /// with fixed calendar dates (not PreviewData, which is relative to "now") so the date-bucketed
    /// sections (Aujourd'hui/Cette semaine/Ce mois) never shift as time passes.
    func test_transactionListView_appearance() async throws {
        let container = DIContainer(
            userId: PreviewData.user.id,
            toasty: PreviewData.toasty,
            authStoring: PreviewData.authStoring,
            authSession: PreviewData.authSession,
            networkMonitor: PreviewData.networkMonitor,
            inMemory: true
        )
        seedInstitutionsAndAccounts(in: container)
        seedFixedDateTransactions(in: container)

        let coordinator = AppCoordinator(
            container: container,
            user: PreviewData.user,
            onSignOut: {},
            onSessionUpdated: { _ in }
        )
        await coordinator.loadData()

        let sut = TransactionListView(coordinator: coordinator)
            .environment(container)
            .asViewController()

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TRANSACTION_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TRANSACTION_LIST_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraSmall)), named: "TRANSACTION_LIST_light_XS")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark, contentSize: .accessibilityExtraExtraExtraLarge)),
              named: "TRANSACTION_LIST_dark_XXXL")
    }

    // MARK: Helpers

    private func seedInstitutionsAndAccounts(in container: DIContainer) {
        let context = container.modelContainer.mainContext
        for institution in PreviewData.institutions {
            context.insert(InstitutionModel(
                id: institution.id,
                userId: institution.userId,
                name: institution.name,
                category: institution.category.rawValue,
                isArchived: institution.isArchived
            ))
        }
        for account in PreviewData.accounts {
            context.insert(AccountModel(
                id: account.id,
                institutionId: account.institutionId,
                name: account.name,
                category: account.category.rawValue
            ))
        }
        try? context.save()
    }

    /// A fixed 2023 date, far enough in the past to always fall outside the "today/this week/this
    /// month" buckets — the section it lands in never changes, unlike a date relative to `Date()`.
    private func fixedDate(day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: day))!
    }

    private func seedFixedDateTransactions(in container: DIContainer) {
        let context = container.modelContainer.mainContext
        let transactions = [
            Transaction(userId: PreviewData.user.id, label: "Salaire mars", date: fixedDate(day: 1),
                       totalAmount: 2500, isExpense: false, category: .salary,
                       splits: [TransactionSplit(accountId: PreviewData.accountCourant.id, amount: 2500)]),
            Transaction(userId: PreviewData.user.id, label: "Restaurant midi", date: fixedDate(day: 5),
                       totalAmount: 30, isExpense: true, category: .restaurant,
                       splits: [
                           TransactionSplit(accountId: PreviewData.accountCourant.id, amount: 15),
                           TransactionSplit(accountId: PreviewData.accountSwile.id, amount: 15)
                       ]),
            Transaction(userId: PreviewData.user.id, label: "Courses Monoprix", date: fixedDate(day: 12),
                       totalAmount: 65, isExpense: true, category: .shopping,
                       splits: [TransactionSplit(accountId: PreviewData.accountCourant.id, amount: 65)])
        ]
        for transaction in transactions {
            let model = TransactionModel(
                id: transaction.id,
                userId: transaction.userId,
                label: transaction.label,
                date: transaction.date,
                totalAmount: transaction.totalAmount,
                note: transaction.note,
                isExpense: transaction.isExpense,
                category: transaction.category.rawValue
            )
            model.splits = transaction.splits.map { TransactionSplitModel(id: $0.id, accountId: $0.accountId, amount: $0.amount) }
            context.insert(model)
        }
        try? context.save()
    }
}
