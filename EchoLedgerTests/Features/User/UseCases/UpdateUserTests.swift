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
        let user = User(displayName: "Bruce|Wayne", email: "batman@gotham.com")
        try await repository.save(user)
        return user.id
    }

    /// Returns a valid UpdateUserInput with sensible defaults.
    private func makeInput(
        id: UUID,
        firstName: String = "Bruce",
        lastName: String = "Wayne",
        email: String = "batman@gotham.com",
        photoURL: String? = nil
    ) -> UpdateUserInput {
        UpdateUserInput(id: id, firstName: firstName, lastName: lastName, email: email, photoURL: photoURL)
    }

    // MARK: Success
    /// Verifies that a valid update calls update on the repository.
    func test_execute_validInput_callsUpdate() async throws {
        let id = try await seedUser()
        try await useCase.execute(makeInput(id: id, firstName: "Bruce", lastName: "Wayne"))
        XCTAssertTrue(repository.didCallUpdate)
    }

    /// Verifies that the displayName stored uses the pipe separator convention.
    func test_execute_validInput_storesDisplayNameWithSeparator() async throws {
        let id = try await seedUser()
        try await useCase.execute(makeInput(id: id, firstName: "Bruce", lastName: "Wayne"))
        let updated = try await repository.fetchCurrent()
        XCTAssertEqual(updated.displayName, "Bruce|Wayne")
    }

    // MARK: First Name Validation
    /// Verifies that an empty first name throws nameTooShort.
    func test_execute_emptyFirstName_throwsNameTooShort() async throws {
        let id = try await seedUser()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id, firstName: ""))
        ) { error in
            XCTAssertEqual(error as? UserError, .nameTooShort)
        }
    }

    /// Verifies that a single character first name throws nameTooShort.
    func test_execute_singleCharFirstName_throwsNameTooShort() async throws {
        let id = try await seedUser()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id, firstName: "B"))
        ) { error in
            XCTAssertEqual(error as? UserError, .nameTooShort)
        }
    }

    /// Verifies that a first name exceeding 50 characters throws nameTooLong.
    func test_execute_firstNameTooLong_throwsNameTooLong() async throws {
        let id = try await seedUser()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id, firstName: String(repeating: "A", count: 51)))
        ) { error in
            XCTAssertEqual(error as? UserError, .nameTooLong)
        }
    }

    // MARK: Last Name Validation
    /// Verifies that an empty last name throws nameTooShort.
    func test_execute_emptyLastName_throwsNameTooShort() async throws {
        let id = try await seedUser()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id, lastName: ""))
        ) { error in
            XCTAssertEqual(error as? UserError, .nameTooShort)
        }
    }

    /// Verifies that a last name exceeding 50 characters throws nameTooLong.
    func test_execute_lastNameTooLong_throwsNameTooLong() async throws {
        let id = try await seedUser()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id, lastName: String(repeating: "A", count: 51)))
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
