//
//  PurgeDeletedEntitiesTests.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 29/07/2026.
//

import XCTest
@testable import EchoLedger

final class PurgeDeletedEntitiesTests: XCTestCase {

    private var repository: DeletedEntityDouble!
    private var useCase: PurgeDeletedEntities!

    override func setUp() {
        super.setUp()
        repository = DeletedEntityDouble()
        useCase = PurgeDeletedEntities(repository: repository)
    }

    override func tearDown() {
        repository = nil
        useCase = nil
        super.tearDown()
    }

    /// Verifies that purging removes every stored deleted entity.
    func test_execute_removesAllEntities() async throws {
        let firstId = UUID()
        let secondId = UUID()
        try await repository.save(DeletedEntity(id: firstId, name: "A", kind: .account))
        try await repository.save(DeletedEntity(id: secondId, name: "B", kind: .institution))

        try await useCase.execute()

        let first = try await repository.fetch(by: firstId)
        let second = try await repository.fetch(by: secondId)
        XCTAssertNil(first)
        XCTAssertNil(second)
    }

    /// Verifies that a repository error is propagated correctly.
    func test_execute_repositoryThrows_propagatesError() async {
        repository.errorToThrow = StubError.failed
        await XCTAssertThrowsErrorAsync(try await useCase.execute())
    }
}

private enum StubError: Error { case failed }
