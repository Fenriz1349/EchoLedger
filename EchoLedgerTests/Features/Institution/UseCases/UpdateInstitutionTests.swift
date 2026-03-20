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
 
    // MARK: Properties
    private var repository: InstitutionDouble!
    private var useCase: UpdateInstitution!
    private let userId = UUID()
 
    // MARK: Setup
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
 
    // MARK: Success
    /// Verifies that a valid update calls update on the repository.
    func test_execute_validInput_callsUpdate() async throws {
        let id = try await seedInstitution()
        try await useCase.execute(id: id, userId: userId, name: "Caisse d'Épargne", type: .bank)
        XCTAssertTrue(repository.didCallUpdate)
    }
 
    /// Verifies that updating with the same name succeeds (no self-duplicate).
    func test_execute_sameNameSameId_succeeds() async throws {
        let id = try await seedInstitution(name: "BNP Paribas")
        try await useCase.execute(id: id, userId: userId, name: "BNP Paribas", type: .insurance)
        XCTAssertTrue(repository.didCallUpdate)
    }
 
    // MARK: Name Validation
    /// Verifies that updating with a name shorter than 2 characters throws nameTooShort.
    func test_execute_nameTooShort_throwsNameTooShort() async throws {
        let id = try await seedInstitution()
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: id, userId: userId, name: "A", type: .bank)
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .nameTooShort)
        }
    }
 
    /// Verifies that updating with a name exceeding 50 characters throws nameTooLong.
    func test_execute_nameTooLong_throwsNameTooLong() async throws {
        let id = try await seedInstitution()
        let longName = String(repeating: "A", count: 51)
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: id, userId: userId, name: longName, type: .bank)
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
            try await useCase.execute(id: id, userId: userId, name: "Caisse d'Épargne", type: .bank)
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .duplicateName)
        }
    }
}
