//
//  GetDeletedEntityTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 29/07/2026.
//

import XCTest
@testable import EchoLedger

final class GetDeletedEntityTests: XCTestCase {

    private var repository: DeletedEntityDouble!
    private var useCase: GetDeletedEntity!

    override func setUp() {
        super.setUp()
        repository = DeletedEntityDouble()
        useCase = GetDeletedEntity(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    /// Verifies that an existing deleted entity's trace is returned.
    @MainActor
    func test_execute_existingId_returnsEntity() async throws {
        let id = UUID()
        try await repository.save(DeletedEntity(id: id, name: "BNP Paribas", kind: .institution))

        let result = try await useCase.execute(id: id)
        XCTAssertEqual(result?.name, "BNP Paribas")
        XCTAssertEqual(result?.kind, .institution)
    }

    /// Verifies that an unknown id returns nil rather than throwing.
    func test_execute_unknownId_returnsNil() async throws {
        let result = try await useCase.execute(id: UUID())
        XCTAssertNil(result)
    }

    /// Verifies that a repository error is propagated correctly.
    func test_execute_repositoryThrows_propagatesError() async {
        repository.errorToThrow = StubError.failed
        await XCTAssertThrowsErrorAsync(try await useCase.execute(id: UUID()))
    }
}

private enum StubError: Error { case failed }
