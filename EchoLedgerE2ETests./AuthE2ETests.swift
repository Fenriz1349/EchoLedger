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
        let localSource = AuthLocalSource()
        localSource.clearUserId()
        localSource.clearAnonymousCreationDate()
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

    /// Verifies that linking an anonymous session to an email/password keeps the same uid.
    func test_anonymousSignIn_thenLinkToPermanentAccount_keepsUid() async throws {
        let anonymousUid = try await authRemoteSource.signInAnonymously()
        XCTAssertFalse(anonymousUid.isEmpty)

        try await authRemoteSource.linkAnonymousToEmail(email: testEmail, password: testPassword)
        try authRemoteSource.signOut()

        let signInUid = try await authRemoteSource.signInWithEmail(email: testEmail, password: testPassword)
        XCTAssertEqual(signInUid, anonymousUid)
    }

    /// Verifies that signing in with the wrong password is rejected by the real Auth service.
    func test_signIn_wrongPassword_throwsInvalidCredentials() async throws {
        _ = try await authRemoteSource.createUserProfile(email: testEmail, password: testPassword)
        try authRemoteSource.signOut()

        do {
            _ = try await authRemoteSource.signInWithEmail(email: testEmail, password: "WrongPassword1!")
            XCTFail("Expected signIn to throw for a wrong password")
        } catch let error as AuthError {
            XCTAssertEqual(error, .invalidCredentials)
        }

        // Sign back in so tearDown can clean up the account it created.
        _ = try await authRemoteSource.signInWithEmail(email: testEmail, password: testPassword)
    }

    /// Verifies that a deleted account can no longer sign in.
    func test_deleteCurrentUser_accountNoLongerExists() async throws {
        _ = try await authRemoteSource.createUserProfile(email: testEmail, password: testPassword)
        try await authRemoteSource.deleteCurrentUser()

        do {
            _ = try await authRemoteSource.signInWithEmail(email: testEmail, password: testPassword)
            XCTFail("Expected signIn to fail after account deletion")
        } catch let error as AuthError {
            XCTAssertEqual(error, .invalidCredentials)
        }
    }
}
