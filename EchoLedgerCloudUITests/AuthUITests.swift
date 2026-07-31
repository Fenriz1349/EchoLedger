//
//  AuthUITests.swift
//  EchoLedgerCloudUITests
//
//  Created by Julien Cotte on 28/07/2026.
//

import XCTest

/// End-to-end UI test driving the real app process (not `@testable import`) through the sign-up flow.
/// Runs against the local Firebase emulator suite only (`--uitesting` launch argument, see `EchoLedgerApp.swift`)
final class AuthUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Verifies that creating a new account through the sign-up form reaches the main app screen,
    /// proving the form fields, validation, and post-auth navigation all work end to end.
    ///
    /// Deletes the account at the end: the emulator's Auth/Firestore data persists across app
    /// relaunches, so a test account left behind leaks into the next normal (non-`--uitesting`)
    /// launch on the same simulator — signing the developer into a leftover test user.
    func test_signUp_reachesMainApp() throws {
        let app = XCUIApplication()
        app.signUpAndReachDashboard()

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
