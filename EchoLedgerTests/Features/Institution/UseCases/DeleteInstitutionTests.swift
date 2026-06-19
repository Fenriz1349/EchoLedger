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

    private var institutionRepository: InstitutionDouble!
    private var accountRepository: AccountDouble!
    private var useCase: DeleteInstitution!
    private let institutionId = UUID()

    override func setUp() {
        super.setUp()
        institutionRepository = InstitutionDouble()
        accountRepository = AccountDouble()
        let deleteAccount = DeleteAccount(
            accountRepository: accountRepository,
            transactionRepository: TransactionDouble(),
            deleteDocument: DocumentDeletingDouble(),
            userId: UUID()
        )
        useCase = DeleteInstitution(
            repository: institutionRepository,
            getAccounts: GetAccounts(repository: accountRepository),
            deleteAccount: deleteAccount
        )
    }

    override func tearDown() {
        institutionRepository = nil
        accountRepository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    private func seedInstitution() async throws {
        try await institutionRepository.save(TestData.institution(id: institutionId))
    }

    // MARK: Tests
    /// Verifies that the institution is removed.
    func test_execute_existingId_institutionDeleted() async throws {
        try await seedInstitution()
        try await useCase.execute(id: institutionId)
        await XCTAssertThrowsErrorAsync(
            try await institutionRepository.fetch(by: institutionId)
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .notFound)
        }
    }

    /// Verifies that the institution's accounts are deleted in cascade.
    func test_execute_deletesLinkedAccounts() async throws {
        try await seedInstitution()
        let accountId = UUID()
        try await accountRepository.save(TestData.account(id: accountId, institutionId: institutionId))
        try await useCase.execute(id: institutionId)
        await XCTAssertThrowsErrorAsync(
            try await accountRepository.fetch(by: accountId)
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
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
