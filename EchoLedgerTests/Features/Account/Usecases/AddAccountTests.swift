//
//  AddAccountTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class AddAccountTests: XCTestCase {

    private var repository: AccountDouble!
    private var useCase: AddAccount!
    private let institutionId = UUID()

    override func setUp() {
        super.setUp()
        repository = AccountDouble()
        useCase = AddAccount(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds an account belonging to the shared institutionId.
    private func seedAccount(name: String = "Livret A") async throws {
        let account = Account(institutionId: institutionId, name: name, category: .savings)
        try await repository.save(account)
    }

    // MARK: Success
    /// Verifies that a valid account is saved to the repository.
    func test_execute_validInput_callsSave() async throws {
        try await useCase.execute(institutionId: institutionId, name: "Livret A", category: .savings)
        XCTAssertTrue(repository.didCallSave)
    }

    /// Verifies that the name is trimmed before being saved.
    func test_execute_nameWithWhitespace_isTrimmed() async throws {
        try await useCase.execute(institutionId: institutionId, name: "  Livret A  ", category: .savings)
        let accounts = try await repository.fetchAll(for: institutionId)
        let savedName = accounts.first?.name
        XCTAssertEqual(savedName, "Livret A")
    }

    // MARK: Name Validation
    /// Verifies that an empty name throws nameTooShort.
    func test_execute_emptyName_throwsNameTooShort() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(institutionId: institutionId, name: "", category: .savings)
        ) { error in
            XCTAssertEqual(error as? AccountError, .nameTooShort)
        }
    }

    /// Verifies that a single character name throws nameTooShort.
    func test_execute_singleCharName_throwsNameTooShort() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(institutionId: institutionId, name: "A", category: .savings)
        ) { error in
            XCTAssertEqual(error as? AccountError, .nameTooShort)
        }
    }

    /// Verifies that a name exceeding 50 characters throws nameTooLong.
    func test_execute_nameTooLong_throwsNameTooLong() async {
        let longName = String(repeating: "A", count: 51)
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(institutionId: institutionId, name: longName, category: .savings)
        ) { error in
            XCTAssertEqual(error as? AccountError, .nameTooLong)
        }
    }

    /// Verifies that a name of exactly 50 characters succeeds.
    func test_execute_nameExactly50Chars_succeeds() async throws {
        let maxName = String(repeating: "A", count: 50)
        try await useCase.execute(institutionId: institutionId, name: maxName, category: .savings)
        XCTAssertTrue(repository.didCallSave)
    }

    // MARK: Duplicate Validation
    /// Verifies that adding an account with the same name throws duplicateName.
    func test_execute_duplicateName_throwsDuplicateName() async throws {
        try await seedAccount(name: "Livret A")
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(institutionId: institutionId, name: "Livret A", category: .savings)
        ) { error in
            XCTAssertEqual(error as? AccountError, .duplicateName)
        }
    }

    /// Verifies that duplicate check is case-insensitive.
    func test_execute_duplicateNameCaseInsensitive_throwsDuplicateName() async throws {
        try await seedAccount(name: "Livret A")
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(institutionId: institutionId, name: "livret a", category: .savings)
        ) { error in
            XCTAssertEqual(error as? AccountError, .duplicateName)
        }
    }

    /// Verifies that the same name can be used in different institutions.
    func test_execute_sameNameDifferentInstitution_succeeds() async throws {
        try await seedAccount(name: "Livret A")
        try await useCase.execute(institutionId: UUID(), name: "Livret A", category: .savings)
        XCTAssertTrue(repository.didCallSave)
    }
}
