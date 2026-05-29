//
//  DeleteDocument.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Deletes a document from Firebase Storage by its download URL.
final class DeleteDocument {

    private let documentSource: DocumentRemoteSource

    init(documentSource: DocumentRemoteSource) {
        self.documentSource = documentSource
    }

    /// - Parameter urlString: The download URL of the document to delete.
    func execute(urlString: String) async throws {
        try await documentSource.deleteDocument(urlString: urlString)
    }
}
