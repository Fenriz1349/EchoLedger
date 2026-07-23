//
//  DocumentSourcing.swift
//  EchoLedger
//
//  Created by Julien Cotte on 19/06/2026.
//

import Foundation

/// Gateway to document I/O, so the document use cases can be unit-tested with a double instead
/// of reaching Firebase Storage. The concrete `DocumentRemoteSource` is exercised only in
/// integration tests.
protocol DocumentSourcing {
    /// Uploads a transaction attachment and returns its download URL.
    func uploadTransactionAttachment(_ data: Data,
                                     mimeType: String,
                                     userId: UUID,
                                     transactionId: UUID) async throws -> String
    /// Uploads an avatar photo for a user and returns its download URL.
    func uploadAvatarPhoto(_ data: Data, userId: UUID) async throws -> String
    /// Downloads the raw bytes of a document from its download URL.
    func downloadImageData(urlString: String) async throws -> Data
    /// Deletes a document by its download URL.
    func deleteDocument(urlString: String) async throws
    /// Deletes every file stored under the user's Storage folder.
    func deleteAllUserFiles(userId: UUID) async throws
}
