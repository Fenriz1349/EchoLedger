//
//  GetInstitutionsTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 20/03/2026.
//

import XCTest
@testable import EchoLedger
 
// MARK: - GetInstitutionsTests

@MainActor
final class GetInstitutionsTests: XCTestCase {
 
    // MARK: Properties
    private var repository: InstitutionRepositoryDouble!
    private var useCase: GetInstitutions!
    private let userId = UUID()
 
    // MARK: Setup
    override func setUp() {
        super.setUp()
        repository = InstitutionRepositoryDouble()
        useCase = GetInstitutions(repository: repository)
    }
 
    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }
 
    // MARK: Helpers
    /// Seeds an institution belonging to the shared userId.
    private func seedInstitution(name: String = "BNP Paribas") async throws {
        let institution = Institution(userId: userId, name: name, type: .bank)
        try await repository.save(institution)
    }
 
    // MARK: Tests
    /// Verifies that all institutions belonging to the user are returned.
    func test_execute_returnsAllInstitutionsForUser() async throws {
        try await seedInstitution(name: "BNP Paribas")
        try await seedInstitution(name: "Caisse d'Épargne")
        let result = try await useCase.execute(for: userId)
        XCTAssertEqual(result.count, 2)
    }
 
    /// Verifies that institutions belonging to a different user are not returned.
    func test_execute_doesNotReturnInstitutionsFromOtherUser() async throws {
        try await seedInstitution()
        let result = try await useCase.execute(for: UUID())
        XCTAssertTrue(result.isEmpty)
    }
 
    /// Verifies that an empty array is returned when no institutions exist.
    func test_execute_noInstitutions_returnsEmpty() async throws {
        let result = try await useCase.execute(for: userId)
        XCTAssertTrue(result.isEmpty)
    }
 
    /// Verifies that a repository error is propagated correctly.
    func test_execute_repositoryThrows_propagatesError() async {
        repository.errorToThrow = InstitutionError.notFound
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(for: userId)
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .notFound)
        }
    }
}
