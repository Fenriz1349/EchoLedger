//
//  UnarchiveInstitutionTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 19/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class UnarchiveInstitutionTests: XCTestCase {

    private var repository: InstitutionDouble!
    private var useCase: UnarchiveInstitution!
    private let institutionId = UUID()

    override func setUp() {
        super.setUp()
        repository = InstitutionDouble()
        useCase = UnarchiveInstitution(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    private func seedArchivedInstitution() async throws {
        try await repository.save(TestData.institution(id: institutionId, isArchived: true))
    }

    // MARK: Tests
    /// Verifies that the institution is restored to active status.
    func test_execute_unarchivesInstitution() async throws {
        try await seedArchivedInstitution()
        try await useCase.execute(id: institutionId)
        let institution = try await repository.fetch(by: institutionId)
        XCTAssertFalse(institution.isArchived)
    }

    /// Verifies that unarchiving an unknown institution throws notFound.
    func test_execute_unknownId_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .notFound)
            XCTAssertEqual((error as? InstitutionError)?.errorDescription, "Établissement introuvable.")
        }
    }
}
