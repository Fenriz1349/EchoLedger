//
//  UpdateUserTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class UpdateUserTests: XCTestCase {

    private var repository: UserDouble!
    private var useCase: UpdateUser!

    override func setUp() {
        super.setUp()
        repository = UserDouble()
        useCase = UpdateUser(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds and returns a user with a known id.
    private func seedUser() async throws -> UUID {
        let user = User(displayName: "Batman", email: "batman@gotham.com")
        try await repository.save(user)
        return user.id
    }

    /// Returns a valid UpdateUserInput with sensible defaults.
    private func makeInput(
        id: UUID,
        displayName: String = "Batman",
        email: String = "batman@gotham.com",
        photoURL: String? = nil
    ) -> UpdateUserInput {
        UpdateUserInput(id: id, displayName: displayName, email: email, photoURL: photoURL)
    }

    // MARK: Success
    /// Verifies that a valid update calls update on the repository.
    func test_execute_validInput_callsUpdate() async throws {
        let id = try await seedUser()
        try await useCase.execute(makeInput(id: id, displayName: "Bruce Wayne"))
        XCTAssertTrue(repository.didCallUpdate)
    }

    // MARK: Name Validation
    /// Verifies that an empty display name throws nameTooShort.
    func test_execute_emptyName_throwsNameTooShort() async throws {
        let id = try await seedUser()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id, displayName: ""))
        ) { error in
            XCTAssertEqual(error as? UserError, .nameTooShort)
        }
    }

    /// Verifies that a single character name throws nameTooShort.
    func test_execute_singleCharName_throwsNameTooShort() async throws {
        let id = try await seedUser()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id, displayName: "B"))
        ) { error in
            XCTAssertEqual(error as? UserError, .nameTooShort)
        }
    }

    /// Verifies that a name exceeding 50 characters throws nameTooLong.
    func test_execute_nameTooLong_throwsNameTooLong() async throws {
        let id = try await seedUser()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id, displayName: String(repeating: "A", count: 51)))
        ) { error in
            XCTAssertEqual(error as? UserError, .nameTooLong)
        }
    }

    // MARK: Email Validation
    /// Verifies that an invalid email throws invalidEmail.
    func test_execute_invalidEmail_throwsInvalidEmail() async throws {
        let id = try await seedUser()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id, email: "notanemail"))
        ) { error in
            XCTAssertEqual(error as? UserError, .invalidEmail)
        }
    }
}
