//
//  DeleteUserRuleTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class DeleteUserRuleTests: XCTestCase {

    private var authRepository: AuthDouble!
    private var userRepository: UserDouble!
    private var institutionRepository: InstitutionDouble!
    private var accountRepository: AccountDouble!
    private var transactionRepository: TransactionDouble!
    private var rule: DeleteUserRule!
    private let userId = UUID()

    override func setUp() {
        super.setUp()
        authRepository = AuthDouble()
        userRepository = UserDouble()
        institutionRepository = InstitutionDouble()
        accountRepository = AccountDouble()
        transactionRepository = TransactionDouble()

        let deleteAccountRule = DeleteAccountRule(
            getTransactionsByAccount: GetTransactionsByAccount(getTransactions: GetTransactions(repository: transactionRepository)),
            deleteTransaction: DeleteTransaction(repository: transactionRepository, deleteDocument: DocumentDeletingDouble()),
            updateTransaction: UpdateTransaction(repository: transactionRepository),
            deleteAccount: DeleteAccount(repository: accountRepository),
            userId: userId
        )
        let deleteInstitutionRule = DeleteInstitutionRule(
            getAccounts: GetAccounts(repository: accountRepository),
            deleteAccountRule: deleteAccountRule,
            deleteInstitution: DeleteInstitution(repository: institutionRepository)
        )
        rule = DeleteUserRule(
            getInstitutions: GetInstitutions(repository: institutionRepository),
            deleteInstitutionRule: deleteInstitutionRule,
            deleteUser: DeleteUser(repository: userRepository, deleteDocument: DocumentDeletingDouble()),
            deleteUserProfile: DeleteUserProfile(repository: authRepository, deleteDocument: DocumentDeletingDouble(), userId: userId),
            userId: userId
        )
    }

    override func tearDown() {
        authRepository = nil
        userRepository = nil
        institutionRepository = nil
        accountRepository = nil
        transactionRepository = nil
        rule = nil
        super.tearDown()
    }

    // MARK: Helpers
    private func seedUser() async throws {
        try await userRepository.save(TestData.user(id: userId))
    }

    // MARK: Tests
    /// Verifies that the user record is deleted.
    func test_execute_deletesUserRecord() async throws {
        try await seedUser()
        try await rule.execute()
        await XCTAssertThrowsErrorAsync(
            try await userRepository.fetchCurrent()
        ) { error in
            XCTAssertEqual(error as? UserError, .notFound)
            XCTAssertEqual((error as? UserError)?.errorDescription, "Utilisateur introuvable.")
        }
    }

    /// Verifies that the Firebase Auth account is deleted.
    func test_execute_deletesAuthAccount() async throws {
        try await seedUser()
        try await rule.execute()
        XCTAssertTrue(authRepository.didCallDeleteUserProfile)
    }

    /// Verifies that the user's institutions are deleted in cascade.
    func test_execute_deletesInstitutions() async throws {
        try await seedUser()
        let institutionId = UUID()
        try await institutionRepository.save(TestData.institution(id: institutionId, userId: userId))
        try await rule.execute()
        await XCTAssertThrowsErrorAsync(
            try await institutionRepository.fetch(by: institutionId)
        ) { error in
            XCTAssertEqual(error as? InstitutionError, .notFound)
            XCTAssertEqual((error as? InstitutionError)?.errorDescription, "Établissement introuvable.")
        }
    }
}
