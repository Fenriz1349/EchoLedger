//
//  TransactionFormViewSnapshotTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 17/07/2026.
//

import XCTest
import SwiftUI
@testable import EchoLedger

@MainActor
final class TransactionFormViewSnapshotTests: XCTestCase {

    /// Verifies the appearance of the "add transaction" form. Overrides the default date (which the
    /// ViewModel sets to `Date()` in create mode) with a fixed one, so the displayed text stays stable.
    func test_transactionFormView_appearance() async throws {
        let viewModel = PreviewHelpers.makeTransactionFormViewModel()
        await viewModel.loadAccounts()
        viewModel.date = Calendar.current.date(from: DateComponents(year: 2023, month: 3, day: 15))!

        let sut = TransactionFormView(viewModel: viewModel).asViewController()

        record(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "TRANSACTION_FORM_light")
        record(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "TRANSACTION_FORM_dark")
        record(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraSmall)),
              named: "TRANSACTION_FORM_light_XS")
        record(snapshot: sut.snapshot(for: .iPhone(style: .dark, contentSize: .accessibilityExtraExtraExtraLarge)),
              named: "TRANSACTION_FORM_dark_XXXL")
    }
}
