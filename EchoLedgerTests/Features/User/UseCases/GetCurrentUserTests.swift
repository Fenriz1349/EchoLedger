//
//  GetCurrentUserTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import XCTest
@testable import EchoLedger

// MARK: - GetCurrentUserTests
@MainActor
final class GetCurrentUserTests: XCTestCase {

    private var repository: UserDouble!
    private var useCase: GetCurrentUser!

    override func setUp() {
        super.setUp()
        repository = UserDouble()
        useCase = GetCurrentUser(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Tests
    /// Verifies that the current user is returned when one exists.
    func test_execute_userExists_returnsUser() async throws {
        let user = User(displayName: "Fen", email: "fen@test.com")
        try await repository.save(user)
        let result = try await useCase.execute()
        let resultName = result.displayName
        XCTAssertEqual(resultName, "Fen")
    }

    /// Verifies that notFound is thrown when no user is authenticated.
    func test_execute_noUser_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute()
        ) { error in
            XCTAssertEqual(error as? UserError, .notFound)
        }
    }

    /// Verifies that a repository error is propagated correctly.
    func test_execute_repositoryThrows_propagatesError() async {
        repository.errorToThrow = UserError.notFound
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute()
        ) { error in
            XCTAssertEqual(error as? UserError, .notFound)
        }
    }
}
