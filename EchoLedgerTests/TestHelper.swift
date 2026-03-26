//
//  TestHelper.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 26/03/2026.
//

import XCTest

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
