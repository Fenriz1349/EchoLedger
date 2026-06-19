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
