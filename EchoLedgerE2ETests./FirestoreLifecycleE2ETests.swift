//
//  FirestoreLifecycleE2ETests.swift
//  EchoLedgerE2ETests.
//
//  Created by Julien Cotte on 19/07/2026.
//

import XCTest
import FirebaseAuth
import FirebaseFirestore
import Toasty
@testable import EchoLedgerCloud

/// Chains institution → account → transaction → update → delete against the real (emulated)
/// Firestore — no doubles. Requires `firebase emulators:start` running before these tests execute.
@MainActor
final class FirestoreLifecycleE2ETests: XCTestCase {

    private var container: DIContainer!
    private var institutionId: UUID!

    private static var isConfigured = false

    override func setUp() async throws {
        try await super.setUp()
        if !Self.isConfigured {
            Auth.auth().useEmulator(withHost: "127.0.0.1", port: 9099)
            let settings = Firestore.firestore().settings
            settings.host = "127.0.0.1:8080"
            settings.isSSLEnabled = false
            Firestore.firestore().settings = settings
            Self.isConfigured = true
        }
        _ = try await Auth.auth().signInAnonymously()

        let userId = UUID()
        container = DIContainer(
            userId: userId,
            toasty: ToastyManager(),
            authStoring: AuthStoring(local: AuthLocalSource(), remote: AuthRemoteSource(), userRemote: UserRemoteSource()),
            authSession: AuthSession(userId: userId, isAnonymous: true),
            networkMonitor: NetworkMonitor()
        )
    }

    override func tearDown() async throws {
        if let institutionId {
            try? await container.deleteInstitutionRule.execute(id: institutionId)
        }
        try? Auth.auth().signOut()
        // Firebase's own signOut doesn't clear the app's separate UserDefaults session marker —
        // left uncleared, the next launch would try to resolve it and touch Firestore too early.
        let localSource = AuthLocalSource()
        localSource.clearUserId()
        localSource.clearAnonymousCreationDate()
        container = nil
        try await super.tearDown()
    }

    /// Verifies the full create → update → delete cycle persists correctly in real Firestore.
    func test_fullLifecycle_persistsCorrectlyInRealFirestore() async throws {
        try await container.addInstitution.execute(AddInstitutionInput(
            userId: container.userId, name: "BNP Paribas", category: .bank, logoURL: nil
        ))
        let institutions = try await container.getInstitutions.execute(for: container.userId)
        let institution = try XCTUnwrap(institutions.first)
        institutionId = institution.id

        let account = try await container.addAccount.execute(
            institutionId: institution.id, name: "Compte courant", category: .checking
        )

        try await container.updateAccount.execute(UpdateAccountInput(
            id: account.id, institutionId: institution.id, name: "Compte joint", category: .checking
        ))
        let updatedAccount = try await container.getAccount.execute(id: account.id)
        XCTAssertEqual(updatedAccount.name, "Compte joint")

        try await container.archiveAccount.execute(id: account.id)
        let archivedAccount = try await container.getAccount.execute(id: account.id)
        XCTAssertTrue(archivedAccount.isArchived)

        let created = try await container.addTransaction.execute(AddTransactionInput(
            userId: container.userId,
            label: "Courses",
            date: Date(),
            totalAmount: 50,
            note: nil,
            isExpense: true,
            category: .shopping,
            splits: [TransactionSplit(accountId: account.id, amount: 50)]
        ))
        let fetchedAfterCreate = try await container.getTransaction.execute(id: created.id)
        XCTAssertEqual(fetchedAfterCreate.totalAmount, 50)

        try await container.updateTransaction.execute(UpdateTransactionInput(
            id: created.id,
            userId: container.userId,
            label: "Courses",
            date: Date(),
            totalAmount: 80,
            note: nil,
            isExpense: true,
            category: .shopping,
            splits: [TransactionSplit(accountId: account.id, amount: 80)]
        ))
        let fetchedAfterUpdate = try await container.getTransaction.execute(id: created.id)
        XCTAssertEqual(fetchedAfterUpdate.totalAmount, 80)

        try await container.deleteTransaction.execute(id: created.id)
        do {
            _ = try await container.getTransaction.execute(id: created.id)
            XCTFail("Expected transaction to no longer exist after deletion")
        } catch let error as TransactionError {
            XCTAssertEqual(error, .notFound)
        }
    }
}
