//
//  AuthE2ETests.swift
//  EchoLedgerE2ETests.
//
//  Created by Julien Cotte on 17/07/2026.
//

import XCTest
import FirebaseAuth
@testable import EchoLedgerCloud

/// Exercises the real Firebase Auth SDK against the local emulator (127.0.0.1:9099) — no doubles,
/// no production project. Requires `firebase emulators:start` running before these tests execute.
@MainActor
final class AuthE2ETests: XCTestCase {

    private var authRemoteSource: AuthRemoteSource!
    private var testEmail: String!
    private let testPassword = "Test1234!"

    private static var isConfigured = false

    override func setUp() {
        super.setUp()
        // The host app already configures Firebase at launch; just redirect Auth to the emulator.
        if !Self.isConfigured {
            Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)
            Self.isConfigured = true
        }
        authRemoteSource = AuthRemoteSource()
        testEmail = "test-\(UUID().uuidString)@echoledger.fr"
    }

    override func tearDown() async throws {
        try? await authRemoteSource.deleteCurrentUser()
        authRemoteSource = nil
        try await super.tearDown()
    }

    /// Verifies that a freshly created account can sign up, then sign in again, against the real
    /// (emulated) Firebase Auth service.
    func test_signUpThenSignIn_succeedsAgainstRealAuthEmulator() async throws {
        let signUpUid = try await authRemoteSource.createUserProfile(email: testEmail, password: testPassword)
        XCTAssertFalse(signUpUid.isEmpty)

        try authRemoteSource.signOut()

        let signInUid = try await authRemoteSource.signInWithEmail(email: testEmail, password: testPassword)
        XCTAssertEqual(signInUid, signUpUid)
    }
}
