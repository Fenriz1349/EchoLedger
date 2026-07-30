//
//  AccountDeleteModeIntegrationTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 30/07/2026.
//

import XCTest
import Toasty
@testable import EchoLedger

/// Verifies that AccountFormViewModel.delete(mode:) dispatches to the correct rule: the same kind
/// of inversion bug once hit with archive/unarchive is possible here (keepHistory vs everything),
/// so the effect on the linked transaction is checked end-to-end rather than just the dispatch.
@MainActor
final class AccountDeleteModeIntegrationTests: XCTestCase {

    private var accountRepository: AccountDouble!
    private var institutionRepository: InstitutionDouble!
    private var transactionRepository: TransactionDouble!
    private var deletedEntityRepository: DeletedEntityDouble!
    private var viewModel: AccountFormViewModel!
    private let userId = UUID()
    private let institutionId = UUID()
    private var accountId = UUID()
    private var transactionId = UUID()

    override func setUp() {
        super.setUp()
        accountRepository = AccountDouble()
        institutionRepository = InstitutionDouble()
        transactionRepository = TransactionDouble()
        deletedEntityRepository = DeletedEntityDouble()
    }

    override func tearDown() {
        accountRepository = nil
        institutionRepository = nil
        transactionRepository = nil
        deletedEntityRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds an institution with one account and one transaction on that account, then builds an
    /// AccountFormViewModel editing that account, wired with real rules over the shared doubles.
    private func seed() async throws {
        try await institutionRepository.save(TestData.institution(id: institutionId, userId: userId))
        accountId = UUID()
        try await accountRepository.save(TestData.account(id: accountId, institutionId: institutionId))
        transactionId = UUID()
        let transaction = Transaction(id: transactionId, userId: userId, label: "T", date: Date(),
                                       totalAmount: 30, isExpense: true, category: .other,
                                       splits: [TransactionSplit(accountId: accountId, amount: 30)])
        try await transactionRepository.save(transaction)

        let retireAccountRule = RetireAccountRule(
            getAccount: GetAccount(repository: accountRepository),
            getInstitution: GetInstitution(repository: institutionRepository),
            recordDeletedEntity: RecordDeletedEntity(repository: deletedEntityRepository),
            deleteAccount: DeleteAccount(repository: accountRepository)
        )
        let deleteAccountRule = DeleteAccountRule(
            getTransactionsByAccount: GetTransactionsByAccount(getTransactions: GetTransactions(repository: transactionRepository)),
            deleteTransaction: DeleteTransaction(repository: transactionRepository, deleteDocument: DocumentDeletingDouble()),
            updateTransaction: UpdateTransaction(repository: transactionRepository),
            deleteAccount: DeleteAccount(repository: accountRepository),
            userId: userId
        )
        let institutionFormViewModel = InstitutionFormViewModel(
            toasty: ToastyManager(),
            addInstitution: AddInstitution(repository: institutionRepository),
            updateInstitution: UpdateInstitution(repository: institutionRepository),
            archiveInstitution: ArchiveInstitutionRule(
                getAccounts: GetAccounts(repository: accountRepository),
                archiveAccount: ArchiveAccount(repository: accountRepository),
                archiveInstitution: ArchiveInstitution(repository: institutionRepository)
            ),
            unarchiveInstitution: UnarchiveInstitutionRule(
                getAccounts: GetAccounts(repository: accountRepository),
                unarchiveAccount: UnarchiveAccount(repository: accountRepository),
                unarchiveInstitution: UnarchiveInstitution(repository: institutionRepository)
            ),
            deleteInstitution: RetireInstitutionRule(
                getInstitution: GetInstitution(repository: institutionRepository),
                getAccounts: GetAccounts(repository: accountRepository),
                retireAccountRule: retireAccountRule,
                recordDeletedEntity: RecordDeletedEntity(repository: deletedEntityRepository),
                deleteInstitution: DeleteInstitution(repository: institutionRepository)
            ),
            getInstitutions: GetInstitutions(repository: institutionRepository),
            userId: userId
        )

        let account = try await accountRepository.fetch(by: accountId)
        viewModel = AccountFormViewModel(
            toasty: ToastyManager(),
            addAccount: AddAccount(repository: accountRepository),
            updateAccount: UpdateAccount(repository: accountRepository),
            archiveAccount: ArchiveAccount(repository: accountRepository),
            unarchiveAccount: UnarchiveAccountRule(
                getAccount: GetAccount(repository: accountRepository),
                unarchiveAccount: UnarchiveAccount(repository: accountRepository),
                getInstitution: GetInstitution(repository: institutionRepository),
                unarchiveInstitution: UnarchiveInstitution(repository: institutionRepository)
            ),
            retireAccount: retireAccountRule,
            deleteAccount: deleteAccountRule,
            addTransaction: AddTransaction(repository: transactionRepository),
            getInstitutions: GetInstitutions(repository: institutionRepository),
            addInstitutionFormViewModel: institutionFormViewModel,
            userId: userId,
            existingAccount: account
        )
    }

    // MARK: Tests

    /// Verifies that .keepHistory deletes the account but leaves its transaction untouched.
    func test_delete_keepHistory_deletesAccountButKeepsTransaction() async throws {
        try await seed()

        await viewModel.delete(mode: .keepHistory)

        await XCTAssertThrowsErrorAsync(
            try await accountRepository.fetch(by: accountId)
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
        }
        let transaction = try await transactionRepository.fetch(by: transactionId)
        XCTAssertEqual(transaction.id, transactionId)
    }

    /// Verifies that .everything deletes both the account and its transaction.
    func test_delete_everything_deletesAccountAndTransaction() async throws {
        try await seed()

        await viewModel.delete(mode: .everything)

        await XCTAssertThrowsErrorAsync(
            try await accountRepository.fetch(by: accountId)
        ) { error in
            XCTAssertEqual(error as? AccountError, .notFound)
        }
        await XCTAssertThrowsErrorAsync(
            try await transactionRepository.fetch(by: transactionId)
        ) { error in
            XCTAssertEqual(error as? TransactionError, .notFound)
        }
    }
}
