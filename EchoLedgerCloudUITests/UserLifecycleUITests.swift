//
//  UserLifecycleUITests.swift
//  EchoLedgerCloudUITests
//
//  Created by Julien Cotte on 28/07/2026.
//

import XCTest

/// Exercises the full account lifecycle: demo mode, data creation, conversion to a permanent account (verifying the data persists through it), then deletion
/// Regression-tests the `LinkAnonymousAccount` and `DeleteUserRule` flows end to end against the real app.
final class UserLifecycleUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func test_demoToRealAccount_dataPersistsThenAccountDeletes() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()

        // Enter demo mode.
        let demoButton = app.buttons["Continuer en mode démo"]
        XCTAssertTrue(demoButton.waitForExistence(timeout: 60),
                      "Expected the auth screen to appear after the loading screen.")
        demoButton.tap()

        let dashboardTab = app.tabBars.buttons["tab.dashboard"]
        XCTAssertTrue(dashboardTab.waitForExistence(timeout: 10),
                      "Expected to reach the main app (dashboard tab) after entering demo mode.")

        // Create the dataset while still anonymous.
        app.createFullDataset()

        // Convert the demo account to a permanent one.
        app.tabBars.buttons["tab.profile"].tap()
        XCTAssertTrue(app.buttons["button.stopDemo"].waitForExistence(timeout: 5),
                      "Expected the anonymous profile screen (demo banner) before conversion.")
        app.buttons["button.showLinkAccountForm"].tap()

        let firstNameField = app.textFields["authField.firstName"]
        firstNameField.tap()
        app.waitForKeyboard()
        firstNameField.typeText("Bruce")

        let lastNameField = app.textFields["authField.lastName"]
        lastNameField.tap()
        app.waitForKeyboard()
        lastNameField.typeText("Wayne")

        let email = "test-\(UUID().uuidString)@echoledger.fr"
        let emailField = app.textFields["authField.email"]
        emailField.tap()
        app.waitForKeyboard()
        emailField.typeText(email)

        let password = "Test1234!"
        let passwordField = app.secureTextFields["authField.password"]
        passwordField.tap()
        app.waitForKeyboard()
        passwordField.clearIfNeeded()
        passwordField.typeText(password)

        let confirmPasswordField = app.secureTextFields["authField.confirmPassword"]
        confirmPasswordField.tap()
        app.waitForKeyboard()
        confirmPasswordField.clearIfNeeded()
        confirmPasswordField.typeText(password)

        app.dismissKeyboardIfNeeded()
        app.buttons["button.linkAccountSubmit"].tap()

        // Verify no longer in demo mode: the real profile screen replaces the anonymous one.
        let deleteAccountButton = app.buttons["button.deleteUserAccount"]
        XCTAssertTrue(deleteAccountButton.waitForExistence(timeout: 10),
                      "Expected the real profile screen (not the demo one) after linking the account.")

        // Verify the data created before conversion persisted.
        app.tabBars.buttons["tab.accounts"].tap()
        XCTAssertTrue(app.staticTexts["Compte courant"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Livret A"].exists)

        // Delete the (now real) account.
        app.tabBars.buttons["tab.profile"].tap()
        deleteAccountButton.tap()
        app.alerts["Supprimer le profil"].buttons["Supprimer"].tap()

        let signUpToggle = app.buttons["Inscription"]
        XCTAssertTrue(signUpToggle.waitForExistence(timeout: 10),
                      "Expected to return to the auth screen after account deletion.")
    }
}
