//
//  AddInstitutionTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import XCTest
@testable import EchoLedger

// MARK: - AddInstitutionTests

@MainActor
final class AddInstitutionTests: XCTestCase {

    // MARK: Properties
    private var repository: InstitutionRepositoryDouble!
    private var useCase: AddInstitution!
    private let userId = UUID()

    // MARK: Setup
    override func setUp() {
        super.setUp()
        repository = InstitutionRepositoryDouble()
        useCase = AddInstitution(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Success
    /// Verifies that a valid institution is saved to the repository.
    func test_execute_validInput_callsSave() async throws {
        try await useCase.execute(userId: userId, name: "BNP Paribas", type: .bank)
        XCTAssertTrue(repository.didCallSave)
    }

    /// Verifies that the name is trimmed before being saved.
    func test_execute_nameWithWhitespace_isTrimmed() async throws {
        try await useCase.execute(userId: userId, name: "  BNP  ", type: .bank)
        let institutions = try await repository.fetchAll(for: userId)
        let savedName = institutions.first?.name
        XCTAssertEqual(savedName, "BNP")
    }

    // MARK: Name Validation
    /// Verifies that an empty name throws nameTooShort.
    func test_execute_emptyName_throwsNameTooShort() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(userId: userId, name: "", type: .bank)
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .nameTooShort)
        }
    }

    /// Verifies that a single character name throws nameTooShort.
    func test_execute_singleCharName_throwsNameTooShort() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(userId: userId, name: "A", type: .bank)
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .nameTooShort)
        }
    }

    /// Verifies that a whitespace-only name throws nameTooShort.
    func test_execute_whitespaceOnlyName_throwsNameTooShort() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(userId: userId, name: "   ", type: .bank)
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .nameTooShort)
        }
    }

    /// Verifies that a name exceeding 50 characters throws nameTooLong.
    func test_execute_nameTooLong_throwsNameTooLong() async {
        let longName = String(repeating: "A", count: 51)
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(userId: userId, name: longName, type: .bank)
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .nameTooLong)
        }
    }

    /// Verifies that a name of exactly 50 characters succeeds.
    func test_execute_nameExactly50Chars_succeeds() async throws {
        let maxName = String(repeating: "A", count: 50)
        try await useCase.execute(userId: userId, name: maxName, type: .bank)
        XCTAssertTrue(repository.didCallSave)
    }

    // MARK: Duplicate Validation
    /// Verifies that adding an institution with the same name throws duplicateName.
    func test_execute_duplicateName_throwsDuplicateName() async throws {
        try await useCase.execute(userId: userId, name: "BNP Paribas", type: .bank)
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(userId: userId, name: "BNP Paribas", type: .bank)
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .duplicateName)
        }
    }

    /// Verifies that duplicate check is case-insensitive.
    func test_execute_duplicateNameCaseInsensitive_throwsDuplicateName() async throws {
        try await useCase.execute(userId: userId, name: "BNP Paribas", type: .bank)
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(userId: userId, name: "bnp paribas", type: .bank)
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .duplicateName)
        }
    }

    /// Verifies that the same name can be used by different users.
    func test_execute_sameNameDifferentUser_succeeds() async throws {
        try await useCase.execute(userId: userId, name: "BNP Paribas", type: .bank)
        try await useCase.execute(userId: UUID(), name: "BNP Paribas", type: .bank)
        XCTAssertTrue(repository.didCallSave)
    }
}
