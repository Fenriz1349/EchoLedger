//
//  DeleteTransaction.swift
//  EchoLedger
//
//  Created by Julien Cotte on 06/03/2026.
//

import Foundation

/// Handles the deletion of a transaction, its splits, and its attachment file.
final class DeleteTransaction {

    private let repository: TransactionProviding
    private let deleteDocument: DeleteDocument

    /// - Parameters:
    ///   - repository: The data contract for transaction persistence.
    ///   - deleteDocument: UseCase for removing the attachment file from storage.
    init(repository: TransactionProviding, deleteDocument: DeleteDocument) {
        self.repository = repository
        self.deleteDocument = deleteDocument
    }

    /// Deletes a transaction, its splits, and its attachment file (if any).
    /// The attachment is deleted first: if that fails, the record is kept so the file is never
    /// left orphaned, and the caller can retry once reachable.
    /// - Parameter id: The unique identifier of the transaction to delete.
    /// - Throws: A storage error if the attachment can't be deleted, or a persistence error.
    func execute(id: UUID) async throws {
        if let transaction = try? await repository.fetch(by: id),
           let attachmentURL = transaction.attachmentURL {
            try await deleteDocument.execute(urlString: attachmentURL)
        }
        try await repository.delete(by: id)
    }
}
