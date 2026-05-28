//
//  UploadTransactionPhoto.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Uploads a photo for a transaction, stores it in Firebase Storage,
/// and updates the transaction's photoURL in the repository.
final class UploadTransactionPhoto {

    private let photoSource: PhotoRemoteSource
    private let transactionRepository: TransactionProviding
    private let userId: UUID

    init(photoSource: PhotoRemoteSource,
         transactionRepository: TransactionProviding,
         userId: UUID) {
        self.photoSource = photoSource
        self.transactionRepository = transactionRepository
        self.userId = userId
    }

    /// - Parameters:
    ///   - data: The image data to upload.
    ///   - transaction: The transaction to attach the photo to.
    /// - Returns: The updated transaction with its new photoURL.
    func execute(data: Data, transaction: Transaction) async throws -> Transaction {
        let url = try await photoSource.uploadTransactionPhoto(
            data,
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
            photoURL: url,
            updatedAt: Date()
        )
        try await transactionRepository.update(updated)
        return updated
    }
}
