//
//  DocumentRemoteSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation
import FirebaseStorage

/// Handles all Firebase Storage read and write operations for documents (images and PDFs).
/// Documents are always remote — no local cache.
/// The MIME contentType is set as standard metadata on every upload.
final class DocumentRemoteSource {

    private let storage = Storage.storage()

    /// Uploads a transaction attachment and returns its download URL.
    /// - Parameters:
    ///   - data: The file data to upload.
    ///   - mimeType: Standard MIME type (e.g. "image/jpeg", "application/pdf").
    ///   - userId: The identifier of the owning user.
    ///   - transactionId: The identifier of the transaction this attachment belongs to.
    /// - Returns: The download URL string for the uploaded attachment.
    func uploadTransactionAttachment(
        _ data: Data,
        mimeType: String,
        userId: UUID,
        transactionId: UUID
    ) async throws -> String {
        let metadata = StorageMetadata()
        metadata.contentType = mimeType
        let fileExtension = mimeType == "application/pdf" ? "pdf" : "jpg"
        let reference = storage.reference()
            .child("users/\(userId.uuidString)/transactions/\(transactionId.uuidString).\(fileExtension)")
        _ = try await reference.putDataAsync(data, metadata: metadata)
        let url = try await reference.downloadURL()
        return url.absoluteString
    }

    /// Uploads an avatar photo for a user and returns its download URL.
    /// - Parameters:
    ///   - data: The image data to upload.
    ///   - userId: The identifier of the owning user.
    /// - Returns: The download URL string for the uploaded avatar.
    func uploadAvatarPhoto(_ data: Data, userId: UUID) async throws -> String {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let reference = storage.reference()
            .child("users/\(userId.uuidString)/avatar.jpg")
        _ = try await reference.putDataAsync(data, metadata: metadata)
        let url = try await reference.downloadURL()
        return url.absoluteString
    }

    /// Deletes a document from Firebase Storage by its download URL.
    /// - Parameter urlString: The download URL of the document to delete.
    func deleteDocument(urlString: String) async throws {
        let reference = storage.reference(forURL: urlString)
        try await reference.delete()
    }
}
