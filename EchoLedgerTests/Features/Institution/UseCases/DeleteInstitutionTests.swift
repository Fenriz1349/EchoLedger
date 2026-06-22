//
//  DeleteInstitutionTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class DeleteInstitutionTests: XCTestCase {

    private var repository: InstitutionDouble!
    private var useCase: DeleteInstitution!
    private let institutionId = UUID()

    override func setUp() {
        super.setUp()
        repository = InstitutionDouble()
        useCase = DeleteInstitution(repository: repository)
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
    /// Verifies that the institution record is removed.
    func test_execute_existingId_institutionDeleted() async throws {
        try await seedInstitution()
        try await useCase.execute(id: institutionId)
        await XCTAssertThrowsErrorAsync(
            try await repository.fetch(by: institutionId)
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .notFound)
        }
    }

    /// Verifies that deleting an unknown institution throws notFound.
    func test_execute_unknownId_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .notFound)
        }
    }
}
