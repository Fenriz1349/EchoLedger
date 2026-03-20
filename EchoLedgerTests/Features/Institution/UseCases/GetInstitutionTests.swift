//
//  GetInstitutionTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class GetInstitutionTests: XCTestCase {
 
    // MARK: Properties
    private var repository: InstitutionDouble!
    private var useCase: GetInstitution!
 
    // MARK: Setup
    override func setUp() {
        super.setUp()
        repository = InstitutionDouble()
        useCase = GetInstitution(repository: repository)
    }
 
    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }
 
    // MARK: Helpers
    /// Seeds and returns an institution with a known id.
    private func seedInstitution() async throws -> UUID {
        let institution = Institution(userId: UUID(), name: "BNP Paribas", type: .bank)
        try await repository.save(institution)
        return institution.id
    }
 
    // MARK: Tests
    /// Verifies that the correct institution is returned for a known id.
    func test_execute_existingId_returnsInstitution() async throws {
        let id = try await seedInstitution()
        let result = try await useCase.execute(id: id)
        let resultId = result.id
        XCTAssertEqual(resultId, id)
    }
 
    /// Verifies that the returned institution has the expected name.
    func test_execute_existingId_returnsCorrectName() async throws {
        let id = try await seedInstitution()
        let result = try await useCase.execute(id: id)
        let resultName = result.name
        XCTAssertEqual(resultName, "BNP Paribas")
    }
 
    /// Verifies that notFound is thrown when no institution matches the id.
    func test_execute_unknownId_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .notFound)
        }
    }
}
