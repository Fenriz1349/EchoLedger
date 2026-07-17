//
//  AccountListViewSnapshotTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 17/07/2026.
//

import XCTest
import SwiftUI
@testable import EchoLedger

@MainActor
final class AccountListViewSnapshotTests: XCTestCase {

    /// Verifies the appearance of the account list, seeded with PreviewData's institutions and accounts.
    func test_accountListView_appearance() async throws {
        let coordinator = PreviewHelpers.appCoordinator
        await coordinator.loadData()

        let sut = AccountListView(coordinator: coordinator)
            .environment(PreviewHelpers.container)
            .asViewController()

        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "ACCOUNT_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "ACCOUNT_LIST_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraSmall)), named: "ACCOUNT_LIST_light_XS")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark, contentSize: .accessibilityExtraExtraExtraLarge)),
              named: "ACCOUNT_LIST_dark_XXXL")
    }
}
