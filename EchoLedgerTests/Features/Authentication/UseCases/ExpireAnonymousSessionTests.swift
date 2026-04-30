//
//  ExpireAnonymousSessionTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 30/04/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class ExpireAnonymousSessionTests: XCTestCase {

    private var repository: AuthDouble!
    private var useCase: ExpireAnonymousSession!

    override func setUp() {
        super.setUp()
        repository = AuthDouble()
        useCase = ExpireAnonymousSession(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Tests

    /// Verifies that execute returns false and does not expire a session that is still valid.
    func test_execute_sessionNotExpired_returnsFalseAndDoesNotExpire() async {
        repository.isExpired = false
        let expired = await useCase.execute()
        XCTAssertFalse(expired)
        XCTAssertFalse(repository.didCallExpire)
    }

    /// Verifies that execute returns true and calls expireAnonymousSession when the session is expired.
    func test_execute_sessionExpired_returnsTrueAndExpires() async {
        repository.isExpired = true
        let expired = await useCase.execute()
        XCTAssertTrue(expired)
        XCTAssertTrue(repository.didCallExpire)
    }

    /// Verifies that expireAnonymousSession is not called a second time if already expired.
    func test_execute_calledTwice_expireCalledOnlyOnFirstExpiredCall() async {
        repository.isExpired = true
        _ = await useCase.execute()
        repository.isExpired = false
        _ = await useCase.execute()
        XCTAssertTrue(repository.didCallExpire)
    }
}
