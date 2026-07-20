//
//  GetAccountsWithInstitutionTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class GetAccountsWithInstitutionTests: XCTestCase {

    private var institutionRepository: InstitutionDouble!
    private var accountRepository: AccountDouble!
    private var useCase: GetAccountsWithInstitution!
    private let userId = UUID()

    override func setUp() {
        super.setUp()
        institutionRepository = InstitutionDouble()
        accountRepository = AccountDouble()
        useCase = GetAccountsWithInstitution(
            getInstitutions: GetInstitutions(repository: institutionRepository),
            getAccounts: GetAccounts(repository: accountRepository)
        )
    }

    override func tearDown() {
        institutionRepository = nil
        accountRepository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Tests
    /// Verifies that each account is paired with its institution's name.
    func test_execute_pairsAccountWithInstitutionName() async throws {
        let institutionId = UUID()
        try await institutionRepository.save(TestData.institution(id: institutionId, userId: userId, name: "BNP"))
        try await accountRepository.save(TestData.account(institutionId: institutionId, name: "Livret A"))
        let items = try await useCase.execute(for: userId, filter: .all)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.account.name, "Livret A")
        XCTAssertEqual(items.first?.institutionName, "BNP")
    }

    /// Verifies that the result is sorted alphabetically by account name.
    func test_execute_sortsByAccountName() async throws {
        let institutionId = UUID()
        try await institutionRepository.save(TestData.institution(id: institutionId, userId: userId))
        try await accountRepository.save(TestData.account(institutionId: institutionId, name: "Zeta"))
        try await accountRepository.save(TestData.account(institutionId: institutionId, name: "Alpha"))
        let items = try await useCase.execute(for: userId, filter: .all)
        XCTAssertEqual(items.map { $0.account.name }, ["Alpha", "Zeta"])
    }

    /// Verifies that the active filter returns only active accounts.
    func test_execute_activeFilter_returnsOnlyActiveAccounts() async throws {
        let institutionId = UUID()
        try await institutionRepository.save(TestData.institution(id: institutionId, userId: userId))
        try await accountRepository.save(TestData.account(institutionId: institutionId, name: "Active"))
        try await accountRepository.save(TestData.account(institutionId: institutionId, name: "Archived", isArchived: true))
        let items = try await useCase.execute(for: userId, filter: .active)
        XCTAssertEqual(items.map { $0.account.name }, ["Active"])
    }

    /// Verifies that no institutions yields an empty result.
    func test_execute_noInstitutions_returnsEmpty() async throws {
        let items = try await useCase.execute(for: userId, filter: .all)
        XCTAssertTrue(items.isEmpty)
    }
}
