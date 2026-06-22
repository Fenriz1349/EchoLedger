//
//  TestHelper.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 26/03/2026.
//

import XCTest
@testable import EchoLedger

/// Centralized factories for domain entities used across tests.
/// Keeps test setup short and consistent; pass only the fields a test actually cares about.
enum TestData {

    static func user(
        id: UUID = UUID(),
        firstName: String = "Bruce",
        lastName: String = "Wayne",
        email: String = "batman@gotham.com",
        photoURL: String? = nil
    ) -> User {
        User(id: id, displayName: "\(firstName)|\(lastName)", email: email, photoURL: photoURL)
    }

    static func institution(
        id: UUID = UUID(),
        userId: UUID = UUID(),
        name: String = "BNP Paribas",
        category: InstitutionCategory = .bank,
        isArchived: Bool = false
    ) -> Institution {
        Institution(id: id, userId: userId, name: name, category: category, isArchived: isArchived)
    }

    static func account(
        id: UUID = UUID(),
        institutionId: UUID = UUID(),
        name: String = "Compte courant",
        category: AccountCategory = .checking,
        isArchived: Bool = false
    ) -> Account {
        Account(id: id, institutionId: institutionId, name: name, category: category, isArchived: isArchived)
    }
}

/// Async variant of XCTAssertThrowsError for use with async throwing functions.
func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        XCTFail("Expected error but none was thrown. \(message())", file: file, line: line)
    } catch {
        errorHandler(error)
    }
}
