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
    func signUpAndReachDashboard(firstName: String = "Jean", lastName: String = "Dupont") -> String {
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
}
