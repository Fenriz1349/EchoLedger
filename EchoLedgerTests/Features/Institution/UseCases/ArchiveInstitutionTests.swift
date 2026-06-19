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

    private var institutionRepository: InstitutionDouble!
    private var accountRepository: AccountDouble!
    private var useCase: ArchiveInstitution!
    private let institutionId = UUID()

    override func setUp() {
        super.setUp()
        institutionRepository = InstitutionDouble()
        accountRepository = AccountDouble()
        useCase = ArchiveInstitution(
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
    /// Seeds an active institution with two active accounts.
    private func seed() async throws {
        try await institutionRepository.save(TestData.institution(id: institutionId))
        try await accountRepository.save(TestData.account(institutionId: institutionId))
        try await accountRepository.save(TestData.account(institutionId: institutionId))
    }

    // MARK: Tests
    /// Verifies that the institution is marked as archived.
    func test_execute_archivesInstitution() async throws {
        try await seed()
        try await useCase.execute(id: institutionId)
        let institution = try await institutionRepository.fetch(by: institutionId)
        XCTAssertTrue(institution.isArchived)
    }

    /// Verifies that every account linked to the institution is archived too.
    func test_execute_archivesLinkedAccounts() async throws {
        try await seed()
        try await useCase.execute(id: institutionId)
        let accounts = try await accountRepository.fetchAll(for: institutionId)
        XCTAssertTrue(accounts.allSatisfy { $0.isArchived })
    }

    /// Verifies that archiving an unknown institution throws notFound.
    func test_execute_unknownId_throwsNotFound() async {
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: UUID())
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .notFound)
        }
    }
}
