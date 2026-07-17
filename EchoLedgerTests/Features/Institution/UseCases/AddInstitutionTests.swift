//
//  AddInstitutionTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class AddInstitutionTests: XCTestCase {

    private var repository: InstitutionDouble!
    private var useCase: AddInstitution!
    private let userId = UUID()

    override func setUp() {
        super.setUp()
        repository = InstitutionDouble()
        useCase = AddInstitution(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Returns a valid AddInstitutionInput with sensible defaults.
    private func makeInput(
        name: String = "BNP Paribas",
        category: InstitutionCategory = .bank,
        logoURL: String? = nil
    ) -> AddInstitutionInput {
        AddInstitutionInput(userId: userId, name: name, category: category, logoURL: logoURL)
    }

    /// Seeds an institution belonging to the shared userId.
    private func seedInstitution(name: String = "BNP Paribas") async throws {
        try await useCase.execute(makeInput(name: name))
    }

    // MARK: Success
    /// Verifies that a valid institution is persisted to the repository.
    func test_execute_validInput_savesInstitution() async throws {
        try await useCase.execute(makeInput())
        let institutions = try await repository.fetchAll(for: userId)
        XCTAssertEqual(institutions.count, 1)
        XCTAssertEqual(institutions.first?.name, "BNP Paribas")
    }

    /// Verifies that the name is trimmed before being saved.
    func test_execute_nameWithWhitespace_isTrimmed() async throws {
        try await useCase.execute(makeInput(name: "  BNP  "))
        let institutions = try await repository.fetchAll(for: userId)
        let savedName = institutions.first?.name
        XCTAssertEqual(savedName, "BNP")
    }

    // MARK: Name Validation
    /// Verifies that an empty name throws nameTooShort.
    func test_execute_emptyName_throwsNameTooShort() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(name: ""))
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .nameTooShort)
            XCTAssertEqual((error as? InstitutionError)?.errorDescription,
                          "Le nom de l'établissement doit contenir au moins 2 caractères.")
        }
    }

    /// Verifies that a single character name throws nameTooShort.
    func test_execute_singleCharName_throwsNameTooShort() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(name: "A"))
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .nameTooShort)
            XCTAssertEqual((error as? InstitutionError)?.errorDescription,
                          "Le nom de l'établissement doit contenir au moins 2 caractères.")
        }
    }

    /// Verifies that a whitespace-only name throws nameTooShort.
    func test_execute_whitespaceOnlyName_throwsNameTooShort() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(name: "   "))
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .nameTooShort)
            XCTAssertEqual((error as? InstitutionError)?.errorDescription,
                          "Le nom de l'établissement doit contenir au moins 2 caractères.")
        }
    }

    /// Verifies that a name exceeding 50 characters throws nameTooLong.
    func test_execute_nameTooLong_throwsNameTooLong() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(name: String(repeating: "A", count: 51)))
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .nameTooLong)
            XCTAssertEqual((error as? InstitutionError)?.errorDescription,
                          "Le nom de l'établissement ne peut pas dépasser 50 caractères.")
        }
    }

    /// Verifies that a name of exactly 50 characters succeeds.
    func test_execute_nameExactly50Chars_succeeds() async throws {
        let name = String(repeating: "A", count: 50)
        try await useCase.execute(makeInput(name: name))
        let institutions = try await repository.fetchAll(for: userId)
        XCTAssertEqual(institutions.first?.name, name)
    }

    // MARK: Duplicate Validation
    /// Verifies that adding an institution with the same name throws duplicateName.
    func test_execute_duplicateName_throwsDuplicateName() async throws {
        try await seedInstitution(name: "BNP Paribas")
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(name: "BNP Paribas"))
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .duplicateName)
            XCTAssertEqual((error as? InstitutionError)?.errorDescription,
                          "Un établissement avec ce nom existe déjà.")
        }
    }

    /// Verifies that duplicate check is case-insensitive.
    func test_execute_duplicateNameCaseInsensitive_throwsDuplicateName() async throws {
        try await seedInstitution(name: "BNP Paribas")
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(name: "bnp paribas"))
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .duplicateName)
            XCTAssertEqual((error as? InstitutionError)?.errorDescription,
                          "Un établissement avec ce nom existe déjà.")
        }
    }

    /// Verifies that the same name can be used by different users.
    func test_execute_sameNameDifferentUser_succeeds() async throws {
        try await seedInstitution(name: "BNP Paribas")
        let otherUserId = UUID()
        let otherInput = AddInstitutionInput(userId: otherUserId, name: "BNP Paribas", category: .bank, logoURL: nil)
        try await useCase.execute(otherInput)
        let otherInstitutions = try await repository.fetchAll(for: otherUserId)
        XCTAssertEqual(otherInstitutions.count, 1)
    }
}
