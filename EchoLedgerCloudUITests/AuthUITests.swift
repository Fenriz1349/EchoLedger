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
    func test_signUp_reachesMainApp() throws {
        XCUIApplication().signUpAndReachDashboard()
    }
}
