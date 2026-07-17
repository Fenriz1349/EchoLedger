//
//  DeleteUserTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import XCTest
@testable import EchoLedger

@MainActor
final class DeleteUserTests: XCTestCase {

    private var repository: UserDouble!
    private var documentDeleting: DocumentDeletingDouble!
    private var useCase: DeleteUser!

    override func setUp() {
        super.setUp()
        repository = UserDouble()
        documentDeleting = DocumentDeletingDouble()
        useCase = DeleteUser(repository: repository, deleteDocument: documentDeleting)
    }

    override func tearDown() {
        repository = nil
        documentDeleting = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Helpers
    /// Seeds the current user (optionally with an avatar) and returns its id.
    private func seedUser(photoURL: String? = nil) async throws -> UUID {
        let user = TestData.user(photoURL: photoURL)
        try await repository.save(user)
        return user.id
    }

    // MARK: Tests
    /// Verifies that the user record is deleted when there is no avatar.
    func test_execute_noAvatar_deletesUser() async throws {
        let id = try await seedUser(photoURL: nil)
        try await useCase.execute(id: id)
        await XCTAssertThrowsErrorAsync(try await repository.fetchCurrent()) { error in
            XCTAssertEqual(error as? UserError, .notFound)
            XCTAssertEqual((error as? UserError)?.errorDescription, "Utilisateur introuvable.")
        }
    }

    /// Verifies that the user record is deleted once the avatar deletion succeeds.
    func test_execute_withAvatar_deletesUser() async throws {
        let id = try await seedUser(photoURL: "https://example.com/avatar.jpg")
        try await useCase.execute(id: id)
        await XCTAssertThrowsErrorAsync(try await repository.fetchCurrent()) { error in
            XCTAssertEqual(error as? UserError, .notFound)
            XCTAssertEqual((error as? UserError)?.errorDescription, "Utilisateur introuvable.")
        }
    }

    /// Verifies that a failing avatar deletion aborts the process and keeps the user record.
    func test_execute_avatarDeletionFails_keepsUser() async throws {
        let id = try await seedUser(photoURL: "https://example.com/avatar.jpg")
        documentDeleting.errorToThrow = StubError.failed
        await XCTAssertThrowsErrorAsync(try await useCase.execute(id: id))
        let stillThere = try await repository.fetchCurrent()
        XCTAssertEqual(stillThere.id, id)
    }
}

private enum StubError: Error { case failed }
