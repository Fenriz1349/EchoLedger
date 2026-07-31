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
    private var useCase: DeleteUser!

    override func setUp() {
        super.setUp()
        repository = UserDouble()
        useCase = DeleteUser(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    // MARK: Tests
    /// Verifies that the user record is deleted. Storage cleanup (avatar included) is now
    /// orchestrated by DeleteUserRule, which sweeps Storage before this record is deleted.
    func test_execute_deletesUser() async throws {
        let user = TestData.user()
        try await repository.save(user)
        try await useCase.execute(id: user.id)
        await XCTAssertThrowsErrorAsync(try await repository.fetchCurrent()) { error in
            XCTAssertEqual(error as? UserError, .notFound)
            XCTAssertEqual((error as? UserError)?.errorDescription, "Utilisateur introuvable.")
        }
    }
}
