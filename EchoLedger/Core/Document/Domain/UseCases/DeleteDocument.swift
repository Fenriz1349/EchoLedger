//
//  DeleteDocument.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Abstraction over document deletion, so the delete use cases can be unit-tested without
/// reaching Firebase Storage (or the network).
protocol DocumentDeleting {
    func execute(urlString: String) async throws
    func deleteAllUserFiles(userId: UUID) async throws
}

/// Deletes a document from Firebase Storage by its download URL.
final class DeleteDocument: DocumentDeleting {

    private let documentSource: DocumentSourcing

    init(documentSource: DocumentSourcing) {
        self.documentSource = documentSource
    }

    /// - Parameter urlString: The download URL of the document to delete.
    func execute(urlString: String) async throws {
        try await documentSource.deleteDocument(urlString: urlString)
    }

    /// Deletes every file under the user's Storage folder. Used on account deletion.
    /// - Parameter userId: The owner whose files should be removed.
    func deleteAllUserFiles(userId: UUID) async throws {
        try await documentSource.deleteAllUserFiles(userId: userId)
    }
}
