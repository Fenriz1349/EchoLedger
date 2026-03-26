//
//  UpdateInstitutionTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class UpdateInstitutionTests: XCTestCase {

    private var repository: InstitutionDouble!
    private var useCase: UpdateInstitution!
    private let userId = UUID()

    override func setUp() {
        super.setUp()
        repository = InstitutionDouble()
        useCase = UpdateInstitution(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds and returns an institution with a known id.
    private func seedInstitution(name: String = "BNP Paribas") async throws -> UUID {
        let institution = Institution(userId: userId, name: name, type: .bank)
        try await repository.save(institution)
        return institution.id
    }

    /// Returns a valid UpdateInstitutionInput with sensible defaults.
    private func makeInput(
        id: UUID,
        name: String = "Caisse d'Épargne",
        type: InstitutionType = .bank
    ) -> UpdateInstitutionInput {
        UpdateInstitutionInput(id: id, userId: userId, name: name, type: type, logoURL: nil)
    }

    // MARK: Success
    /// Verifies that a valid update calls update on the repository.
    func test_execute_validInput_callsUpdate() async throws {
        let id = try await seedInstitution()
        try await useCase.execute(makeInput(id: id))
        XCTAssertTrue(repository.didCallUpdate)
    }

    /// Verifies that updating with the same name succeeds (no self-duplicate).
    func test_execute_sameNameSameId_succeeds() async throws {
        let id = try await seedInstitution(name: "BNP Paribas")
        try await useCase.execute(makeInput(id: id, name: "BNP Paribas", type: .insurance))
        XCTAssertTrue(repository.didCallUpdate)
    }

    // MARK: Name Validation
    /// Verifies that updating with a name shorter than 2 characters throws nameTooShort.
    func test_execute_nameTooShort_throwsNameTooShort() async throws {
        let id = try await seedInstitution()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id, name: "A"))
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .nameTooShort)
        }
    }

    /// Verifies that updating with a name exceeding 50 characters throws nameTooLong.
    func test_execute_nameTooLong_throwsNameTooLong() async throws {
        let id = try await seedInstitution()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id, name: String(repeating: "A", count: 51)))
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .nameTooLong)
        }
    }

    // MARK: Duplicate Validation
    /// Verifies that updating with a name already used by another institution throws duplicateName.
    func test_execute_duplicateName_throwsDuplicateName() async throws {
        try await seedInstitution(name: "Caisse d'Épargne")
        let id = try await seedInstitution(name: "BNP Paribas")
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(makeInput(id: id, name: "Caisse d'Épargne"))
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .duplicateName)
        }
    }
}
