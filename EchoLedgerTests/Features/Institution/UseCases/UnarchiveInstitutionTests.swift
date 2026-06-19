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

    private var institutionRepository: InstitutionDouble!
    private var accountRepository: AccountDouble!
    private var useCase: UnarchiveInstitution!
    private let institutionId = UUID()

    override func setUp() {
        super.setUp()
        institutionRepository = InstitutionDouble()
        accountRepository = AccountDouble()
        useCase = UnarchiveInstitution(
            institutionRepository: institutionRepository,
            accountRepository: accountRepository
        )
    }

    override func tearDown() {
        institutionRepository = nil
        accountRepository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds an archived institution with two archived accounts.
    private func seed() async throws {
        try await institutionRepository.save(TestData.institution(id: institutionId, isArchived: true))
        try await accountRepository.save(TestData.account(institutionId: institutionId, isArchived: true))
        try await accountRepository.save(TestData.account(institutionId: institutionId, isArchived: true))
    }

    // MARK: Tests
    /// Verifies that the institution is restored to active status.
    func test_execute_unarchivesInstitution() async throws {
        try await seed()
        try await useCase.execute(id: institutionId)
        let institution = try await institutionRepository.fetch(by: institutionId)
        XCTAssertFalse(institution.isArchived)
    }

    /// Verifies that every account linked to the institution is restored too.
    func test_execute_unarchivesLinkedAccounts() async throws {
        try await seed()
        try await useCase.execute(id: institutionId)
        let accounts = try await accountRepository.fetchAll(for: institutionId)
        XCTAssertTrue(accounts.allSatisfy { !$0.isArchived })
    }

    /// Verifies that unarchiving an unknown institution throws notFound.
    func test_execute_unknownId_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .notFound)
        }
    }
}
