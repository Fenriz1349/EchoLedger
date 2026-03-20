//
//  UpdateAccountTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class UpdateAccountTests: XCTestCase {

    private var repository: AccountDouble!
    private var useCase: UpdateAccount!
    private let institutionId = UUID()

    override func setUp() {
        super.setUp()
        repository = AccountDouble()
        useCase = UpdateAccount(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds and returns an account with a known id.
    func seedAccount(name: String = "Livret A") async throws -> UUID {
        let account = Account(institutionId: institutionId, name: name, type: .savings)
        try await repository.save(account)
        return account.id
    }

    // MARK: Success
    /// Verifies that a valid update calls update on the repository.
    func test_execute_validInput_callsUpdate() async throws {
        let id = try await seedAccount()
        try await useCase.execute(id: id, institutionId: institutionId, name: "PEL", type: .savings)
        XCTAssertTrue(repository.didCallUpdate)
    }

    /// Verifies that updating with the same name succeeds (no self-duplicate).
    func test_execute_sameNameSameId_succeeds() async throws {
        let id = try await seedAccount(name: "Livret A")
        try await useCase.execute(id: id, institutionId: institutionId, name: "Livret A", type: .creditCard)
        XCTAssertTrue(repository.didCallUpdate)
    }

    // MARK: Validation
    /// Verifies that updating with a name shorter than 2 characters throws nameTooShort.
    func test_execute_nameTooShort_throwsNameTooShort() async throws {
        let id = try await seedAccount()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: id, institutionId: institutionId, name: "A", type: .savings)
        ) { error in
            XCTAssertEqual(error as? AccountError, .nameTooShort)
        }
    }

    /// Verifies that updating with a name exceeding 50 characters throws nameTooLong.
    func test_execute_nameTooLong_throwsNameTooLong() async throws {
        let id = try await seedAccount()
        let longName = String(repeating: "A", count: 51)
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: id, institutionId: institutionId, name: longName, type: .savings)
        ) { error in
            XCTAssertEqual(error as? AccountError, .nameTooLong)
        }
    }

    /// Verifies that updating with a name already used by another account throws duplicateName.
    func test_execute_duplicateName_throwsDuplicateName() async throws {
        try await seedAccount(name: "PEL")
        let id = try await seedAccount(name: "Livret A")
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: id, institutionId: institutionId, name: "PEL", type: .savings)
        ) { error in
            XCTAssertEqual(error as? AccountError, .duplicateName)
        }
    }
}
