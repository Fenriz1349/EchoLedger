//
//  ArchiveInstitutionTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 19/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class ArchiveInstitutionTests: XCTestCase {

    private var repository: InstitutionDouble!
    private var useCase: ArchiveInstitution!
    private let institutionId = UUID()

    override func setUp() {
        super.setUp()
        repository = InstitutionDouble()
        useCase = ArchiveInstitution(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    private func seedInstitution() async throws {
        try await repository.save(TestData.institution(id: institutionId))
    }

    // MARK: Tests
    /// Verifies that the institution is marked as archived.
    func test_execute_archivesInstitution() async throws {
        try await seedInstitution()
        try await useCase.execute(id: institutionId)
        let institution = try await repository.fetch(by: institutionId)
        XCTAssertTrue(institution.isArchived)
    }

    /// Verifies that archiving an unknown institution throws notFound.
    func test_execute_unknownId_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .notFound)
            XCTAssertEqual((error as? InstitutionError)?.errorDescription, "Établissement introuvable.")
        }
    }
}
