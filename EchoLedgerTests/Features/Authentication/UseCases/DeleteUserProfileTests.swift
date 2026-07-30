//
//  DeleteUserProfileTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class DeleteUserProfileTests: XCTestCase {

    private var repository: AuthDouble!
    private var useCase: DeleteUserProfile!

    override func setUp() {
        super.setUp()
        repository = AuthDouble()
        useCase = DeleteUserProfile(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Tests
    /// Verifies that the Auth account is deleted. Storage cleanup is now orchestrated by
    /// DeleteUserRule, which sweeps Storage before this, the very last step, runs.
    func test_execute_deletesAuthAccount() async throws {
        try await useCase.execute()
        XCTAssertTrue(repository.didCallDeleteUserProfile)
    }
}
