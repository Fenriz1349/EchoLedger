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

    // MARK: Properties
    private var repository: InstitutionDouble!
    private var useCase: DeleteInstitution!

    // MARK: Setup
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
    /// Seeds and returns an institution with a known id.
    private func seedInstitution() async throws -> UUID {
        let institution = Institution(userId: UUID(), name: "BNP Paribas", category: .bank)
        try await repository.save(institution)
        return institution.id
    }

    // MARK: Tests
    /// Verifies that an existing institution is deleted and didCallDelete is set.
    func test_execute_existingId_callsDelete() async throws {
        let id = try await seedInstitution()
        try await useCase.execute(id: id)
        XCTAssertTrue(repository.didCallDelete)
    }

    /// Verifies that the institution is no longer fetchable after deletion.
    func test_execute_existingId_institutionNoLongerExists() async throws {
        let id = try await seedInstitution()
        try await useCase.execute(id: id)
        await XCTAssertThrowsErrorAsync(
            try await repository.fetch(by: id)
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .notFound)
        }
    }

    /// Verifies that deleting an unknown id throws notFound.
    func test_execute_unknownId_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .notFound)
        }
    }
}
