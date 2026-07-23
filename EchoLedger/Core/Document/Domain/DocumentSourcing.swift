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
    func uploadTransactionAttachment(_ data: Data,
                                     mimeType: String,
                                     userId: UUID,
                                     transactionId: UUID) async throws -> String
    func uploadAvatarPhoto(_ data: Data, userId: UUID) async throws -> String
    func downloadImageData(urlString: String) async throws -> Data
    func deleteDocument(urlString: String) async throws
    func deleteAllUserFiles(userId: UUID) async throws
}
