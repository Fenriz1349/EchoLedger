//
//  DeleteUserProfileTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class DeleteUserProfileTests: XCTestCase {

    private var repository: AuthDouble!
    private var documentDeleting: DocumentDeletingDouble!
    private var useCase: DeleteUserProfile!
    private let userId = UUID()

    override func setUp() {
        super.setUp()
        repository = AuthDouble()
        documentDeleting = DocumentDeletingDouble()
        useCase = DeleteUserProfile(repository: repository, deleteDocument: documentDeleting, userId: userId)
    }

    override func tearDown() {
        repository = nil
        documentDeleting = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Tests
    /// Verifies that the Auth account is deleted.
    func test_execute_deletesAuthAccount() async throws {
        try await useCase.execute()
        XCTAssertTrue(repository.didCallDeleteUserProfile)
    }

    /// Verifies that a failing file sweep aborts before the Auth account is deleted.
    func test_execute_fileSweepFails_doesNotDeleteAccount() async {
        documentDeleting.errorToThrow = StubError.failed
        await XCTAssertThrowsErrorAsync(try await useCase.execute())
        XCTAssertFalse(repository.didCallDeleteUserProfile)
    }
}

private enum StubError: Error { case failed }
