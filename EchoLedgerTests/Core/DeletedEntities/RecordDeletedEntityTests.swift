//
//  RecordDeletedEntityTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 29/07/2026.
//

import XCTest
@testable import EchoLedger

final class RecordDeletedEntityTests: XCTestCase {

    private var repository: DeletedEntityDouble!
    private var useCase: RecordDeletedEntity!

    override func setUp() {
        super.setUp()
        repository = DeletedEntityDouble()
        useCase = RecordDeletedEntity(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    /// Verifies that recording a deleted entity persists it with the given id, name, and kind.
    func test_execute_savesEntityWithGivenValues() async throws {
        let id = UUID()
        try await useCase.execute(id: id, name: "Livret A", kind: .account)

        let saved = try await repository.fetch(by: id)
        XCTAssertEqual(saved?.name, "Livret A")
        XCTAssertEqual(saved?.kind, .account)
    }

    /// Verifies that a repository error is propagated correctly.
    func test_execute_repositoryThrows_propagatesError() async {
        repository.errorToThrow = StubError.failed
        await XCTAssertThrowsErrorAsync(
            try await useCase.execute(id: UUID(), name: "BNP Paribas", kind: .institution)
        )
    }
}

private enum StubError: Error { case failed }
