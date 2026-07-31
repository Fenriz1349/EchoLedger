//
//  SignOutSignInUITests.swift
//  EchoLedgerCloudUITests
//
//  Created by Julien Cotte on 31/07/2026.
//

import XCTest

/// Verifies that data survives a real sign-out/sign-in cycle (email/password), exercising
/// `ResolveSession` and `SignInWithEmail` — a different path than `UserLifecycleUITests`, which
/// covers persistence through anonymous-to-permanent conversion (`LinkAnonymousAccount`) instead.
final class SignOutSignInUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func test_signOutThenSignIn_dataPersists() throws {
        let app = XCUIApplication()
        let email = app.signUpAndReachDashboard()
        app.createFullDataset()

        // Sign out.
        app.tabBars.buttons["tab.profile"].tap()
        let signOutButton = app.buttons["button.signOut"]
        XCTAssertTrue(signOutButton.waitForExistence(timeout: 5))
        signOutButton.tap()

        // Back on the auth screen, already in sign-in mode by default.
        let emailField = app.textFields["authField.email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 10),
                      "Expected the auth screen to appear after signing out.")
        emailField.tap()
        app.waitForKeyboard()
        emailField.typeText(email)

        let passwordField = app.secureTextFields["authField.password"]
        passwordField.tap()
        app.waitForKeyboard()
        passwordField.clearIfNeeded()
        passwordField.typeText("Test1234!")

        app.dismissKeyboardIfNeeded()
        app.buttons["button.authSubmit"].tap()

        let dashboardTab = app.tabBars.buttons["tab.dashboard"]
        XCTAssertTrue(dashboardTab.waitForExistence(timeout: 10),
                      "Expected to reach the main app (dashboard tab) after signing back in.")

        // Verify the data created before sign-out persisted.
        app.tabBars.buttons["tab.accounts"].tap()
        XCTAssertTrue(app.staticTexts["Compte courant"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Livret A"].exists)

        // Cleanup: delete the test account.
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
