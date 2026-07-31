//
//  UITestsHelper.swift
//  EchoLedgerCloudUITests
//
//  Created by Julien Cotte on 30/07/2026.
//

import XCTest

/// Shared XCUITest helpers for form-filling mechanics (keyboard timing, dismissal, field cleanup)
/// that come up in every screen with text input, not just authentication.
extension XCUIApplication {

    /// Waits for the software keyboard to actually be on screen before typing — tapping a field and
    /// typing immediately can outrun the keyboard's appearance/reconfiguration animation, dropping
    /// or misdirecting the first synthesized keystrokes.
    func waitForKeyboard(timeout: TimeInterval = 3) {
        _ = keyboards.element.waitForExistence(timeout: timeout)
    }

    /// Dismisses the software keyboard via its Return key, if one is showing — trying both the
    /// capitalized and lowercase accessibility labels since the exact one varies by keyboard type.
    func dismissKeyboardIfNeeded() {
        for label in ["Return", "return", "Done", "done"] where keyboards.buttons[label].exists {
            keyboards.buttons[label].tap()
            return
        }
    }
}

extension XCUIElement {

    /// Clears any pre-existing value (e.g. an autofilled suggested password) from a field before
    /// typing, so the field ends up holding exactly the text we type — never a mix of the two.
    func clearIfNeeded() {
        guard let value = value as? String, !value.isEmpty else { return }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count)
        typeText(deleteString)
    }
}

extension XCUIApplication {

    /// Launches the app fresh and signs up a brand new user through the UI, waiting until the
    /// dashboard tab confirms sign-up succeeded. Every UI test starts from a blank dataset
    /// (`--uitesting` wipes any local session at launch), so most test suites need this as their
    /// entry point before exercising their own scenario.
    /// - Returns: The email used to sign up (randomised per call, since the emulator's Auth data
    ///   persists across launches — a fixed email would collide with a previous run's account).
    @discardableResult
    func signUpAndReachDashboard(firstName: String = "Bruce", lastName: String = "Wayne") -> String {
        launchArguments = ["--uitesting"]
        launch()

        // Cold builds can take a long time to install/launch/init Firebase on simulator —
        // generous timeout so this doesn't fail on slow machines or first runs after a rebuild.
        let signUpToggle = buttons["Inscription"]
        XCTAssertTrue(signUpToggle.waitForExistence(timeout: 60),
                      "Expected the auth screen to appear after the loading screen.")
        signUpToggle.tap()

        let firstNameField = textFields["authField.firstName"]
        XCTAssertTrue(firstNameField.waitForExistence(timeout: 5))
        firstNameField.tap()
        waitForKeyboard()
        firstNameField.typeText(firstName)

        let lastNameField = textFields["authField.lastName"]
        lastNameField.tap()
        waitForKeyboard()
        lastNameField.typeText(lastName)

        let email = "test-\(UUID().uuidString)@echoledger.fr"
        let emailField = textFields["authField.email"]
        emailField.tap()
        waitForKeyboard()
        emailField.typeText(email)

        let password = "Test1234!"
        let passwordField = secureTextFields["authField.password"]
        passwordField.tap()
        waitForKeyboard()
        passwordField.clearIfNeeded()
        passwordField.typeText(password)
        XCTAssertEqual(passwordField.value as? String, String(repeating: "•", count: password.count),
                       "Password field doesn't hold the expected text — the strong-password " +
                       "suggestion likely pre-filled or intercepted it.")

        let confirmPasswordField = secureTextFields["authField.confirmPassword"]
        confirmPasswordField.tap()
        waitForKeyboard()
        confirmPasswordField.clearIfNeeded()
        confirmPasswordField.typeText(password)

        // The keyboard can still cover the submit button — a tap there would land on the keyboard
        // instead, since XCUITest taps whatever's on top at that screen location.
        dismissKeyboardIfNeeded()
        buttons["button.authSubmit"].tap()

        let dashboardTab = tabBars.buttons["tab.dashboard"]
        XCTAssertTrue(dashboardTab.waitForExistence(timeout: 10),
                      "Expected to reach the main app (dashboard tab) after sign-up.")
        return email
    }

    /// Creates one institution, two accounts in that institution, one transaction on the first
    /// account, and one transfer from the first to the second account. Shared fixture data for any
    /// scenario that needs a populated dataset to exercise — persistence checks, deletion, etc.
    /// Assumes the app is already past sign-up/sign-in (see `signUpAndReachDashboard()`).
    func createFullDataset(
        institutionName: String = "BNP Paribas",
        firstAccountName: String = "Compte courant",
        firstAccountInitialBalance: String = "1500",
        secondAccountName: String = "Livret A",
        secondAccountInitialBalance: String = "3000",
        transactionLabel: String = "Courses",
        transactionAmount: String = "42"
    ) {
        tabBars.buttons["tab.accounts"].tap()

        // First account — no institution exists yet, so create one inline.
        buttons["button.addAccount"].tap()
        let accountNameField = textFields["accountField.name"]
        XCTAssertTrue(accountNameField.waitForExistence(timeout: 5))

        buttons["button.toggleNewInstitution"].tap()
        let institutionNameField = textFields["institutionField.name"]
        XCTAssertTrue(institutionNameField.waitForExistence(timeout: 5))
        institutionNameField.tap()
        waitForKeyboard()
        institutionNameField.typeText(institutionName)
        dismissKeyboardIfNeeded()
        buttons["button.institutionSubmit"].tap()

        accountNameField.tap()
        waitForKeyboard()
        accountNameField.typeText(firstAccountName)
        let firstBalanceField = textFields["accountField.initialBalance"]
        firstBalanceField.tap()
        waitForKeyboard()
        firstBalanceField.typeText(firstAccountInitialBalance)
        dismissKeyboardIfNeeded()
        buttons["button.accountSubmit"].tap()
        XCTAssertTrue(tabBars.buttons["tab.accounts"].waitForExistence(timeout: 5))

        // Second account — same institution, already selectable by default.
        buttons["button.addAccount"].tap()
        let secondAccountNameField = textFields["accountField.name"]
        XCTAssertTrue(secondAccountNameField.waitForExistence(timeout: 5))
        secondAccountNameField.tap()
        waitForKeyboard()
        secondAccountNameField.typeText(secondAccountName)
        let secondBalanceField = textFields["accountField.initialBalance"]
        secondBalanceField.tap()
        waitForKeyboard()
        secondBalanceField.typeText(secondAccountInitialBalance)
        dismissKeyboardIfNeeded()
        buttons["button.accountSubmit"].tap()
        XCTAssertTrue(tabBars.buttons["tab.accounts"].waitForExistence(timeout: 5))

        // Transaction on the first account.
        buttons["button.addTransaction"].tap()
        let splitAmountField = textFields["transactionField.splitAmount"].firstMatch
        XCTAssertTrue(splitAmountField.waitForExistence(timeout: 5))
        splitAmountField.tap()
        waitForKeyboard()
        splitAmountField.typeText(transactionAmount)

        let labelField = textFields["transactionField.label"]
        labelField.tap()
        waitForKeyboard()
        labelField.typeText(transactionLabel)
        dismissKeyboardIfNeeded()
        buttons["button.transactionSubmit"].tap()
        XCTAssertTrue(tabBars.buttons["tab.dashboard"].waitForExistence(timeout: 5)
                      || tabBars.buttons["tab.transactions"].waitForExistence(timeout: 5))

        // Transfer from the first to the second account.
        tabBars.buttons["tab.accounts"].tap()
        buttons["button.addTransfer"].tap()
        let transferAmountField = textFields["transferField.amount"]
        XCTAssertTrue(transferAmountField.waitForExistence(timeout: 5))
        transferAmountField.tap()
        waitForKeyboard()
        transferAmountField.typeText("10")
        dismissKeyboardIfNeeded()
        buttons["button.transferSubmit"].tap()
    }
}
