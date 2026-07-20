//
//  DocumentDeletingDouble.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 22/06/2026.
//

import Foundation
@testable import EchoLedger

/// In-memory test double for `DocumentDeleting`. No-op by default; set `errorToThrow` to simulate
/// a storage failure (e.g. to verify that a failing file deletion aborts the surrounding process).
final class DocumentDeletingDouble: DocumentDeleting {

    /// Set this to force any method to throw a specific error.
    var errorToThrow: Error?

    func execute(urlString: String) async throws {
        if let error = errorToThrow { throw error }
    }

    func deleteAllUserFiles(userId: UUID) async throws {
        if let error = errorToThrow { throw error }
    }
}
