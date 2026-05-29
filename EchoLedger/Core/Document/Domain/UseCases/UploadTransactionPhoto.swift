//
//  UploadTransactionDocument.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Uploads an attachment for a transaction (image or PDF) to Firebase Storage,
/// stores the download URL and its standard MIME type in the transaction repository.
final class UploadTransactionDocument {

    private let documentSource: DocumentRemoteSource
    private let transactionRepository: TransactionProviding
    private let userId: UUID

    init(documentSource: DocumentRemoteSource,
         transactionRepository: TransactionProviding,
         userId: UUID) {
        self.documentSource = documentSource
        self.transactionRepository = transactionRepository
        self.userId = userId
    }

    /// - Parameters:
    ///   - data: The file data to upload.
    ///   - attachmentType: The type of the attachment — mapped to a standard MIME type for storage.
    ///   - transaction: The transaction to attach the file to.
    /// - Returns: The updated transaction with its new attachmentURL and attachmentContentType.
    func execute(data: Data, attachmentType: AttachmentType, transaction: Transaction) async throws -> Transaction {
        let mimeType = attachmentType == .pdf ? "application/pdf" : "image/jpeg"
        let url = try await documentSource.uploadTransactionAttachment(
            data,
            mimeType: mimeType,
            userId: userId,
            transactionId: transaction.id
        )
        let updated = Transaction(
            id: transaction.id,
            userId: transaction.userId,
            label: transaction.label,
            date: transaction.date,
            totalAmount: transaction.totalAmount,
            note: transaction.note,
            isExpense: transaction.isExpense,
            category: transaction.category,
            splits: transaction.splits,
            attachmentURL: url,
            attachmentContentType: mimeType,
            updatedAt: Date()
        )
        try await transactionRepository.update(updated)
        return updated
    }
}
