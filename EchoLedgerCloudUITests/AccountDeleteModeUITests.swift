//
//  AccountDeleteModeUITests.swift
//  EchoLedgerCloudUITests
//
//  Created by Julien Cotte on 31/07/2026.
//

import XCTest

/// Exercises account-level deletion in both modes — "keep history" vs "everything" — introduced
/// this session via `RetireAccountRule`/`DeleteAccountRule`. Verifies the UI-facing behavior that
/// the unit/integration tests can't: the confirmation dialog, the resulting account-list state,
/// and whether a deleted account's transaction survives in the transaction history.
final class AccountDeleteModeUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func test_deleteAccount_keepHistoryThenEverything() throws {
        let app = XCUIApplication()
        app.signUpAndReachDashboard()
        app.createFullDataset()

        // Delete the first account, keeping its history.
        app.tabBars.buttons["tab.accounts"].tap()
        let firstAccountRow = app.staticTexts["Compte courant"]
        XCTAssertTrue(firstAccountRow.waitForExistence(timeout: 5))
        firstAccountRow.swipeLeft()
        app.buttons["Modifier"].tap()

        let deleteButton = app.buttons["button.deleteAccount"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))
        deleteButton.tap()
        app.buttons["Garder l'historique"].tap()
        app.alerts["Confirmer la suppression"].buttons["Supprimer"].tap()

        // Back on the accounts list: the deleted account is gone.
        XCTAssertTrue(app.tabBars.buttons["tab.accounts"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["Compte courant"].waitForExistence(timeout: 3))

        // Its transaction survives in the history, since we kept it.
        app.tabBars.buttons["tab.transactions"].tap()
        XCTAssertTrue(app.staticTexts["Courses"].waitForExistence(timeout: 5))

        // Delete the second account, this time erasing everything.
        app.tabBars.buttons["tab.accounts"].tap()
        let secondAccountRow = app.staticTexts["Livret A"]
        XCTAssertTrue(secondAccountRow.waitForExistence(timeout: 5))
        secondAccountRow.swipeLeft()
        app.buttons["Modifier"].tap()

        XCTAssertTrue(deleteButton.waitForExistence(timeout: 5))
        deleteButton.tap()
        app.buttons["Tout supprimer"].tap()
        app.alerts["Confirmer la suppression"].buttons["Supprimer"].tap()

        XCTAssertTrue(app.tabBars.buttons["tab.accounts"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["Livret A"].waitForExistence(timeout: 3))

        // Cleanup: delete the whole test account.
        app.tabBars.buttons["tab.profile"].tap()
        let deleteAccountButton = app.buttons["button.deleteUserAccount"]
        XCTAssertTrue(deleteAccountButton.waitForExistence(timeout: 5))
        deleteAccountButton.tap()
        app.alerts["Supprimer le profil"].buttons["Supprimer"].tap()

        let signUpToggle = app.buttons["Inscription"]
        XCTAssertTrue(signUpToggle.waitForExistence(timeout: 10),
                      "Expected to return to the auth screen after account deletion.")
    }
}
