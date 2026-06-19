//
//  DocumentRemoteSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation
import FirebaseStorage

/// Gateway to document I/O, so the document use cases can be unit-tested with a double instead
/// of reaching Firebase Storage. The concrete `DocumentRemoteSource` is exercised only in
/// integration tests.
protocol DocumentSourcing {
    func uploadTransactionAttachment(_ data: Data, mimeType: String, userId: UUID, transactionId: UUID) async throws -> String
    func uploadAvatarPhoto(_ data: Data, userId: UUID) async throws -> String
    func downloadImageData(urlString: String) async throws -> Data
    func deleteDocument(urlString: String) async throws
    func deleteAllUserFiles(userId: UUID) async throws
}

/// Handles all Firebase Storage read and write operations for documents (images and PDFs).
/// Documents are always remote — no local cache.
/// The MIME contentType is set as standard metadata on every upload.
final class DocumentRemoteSource: DocumentSourcing {

    private let storage = Storage.storage()
    private let networkMonitor: NetworkMonitor

    init(networkMonitor: NetworkMonitor) {
        self.networkMonitor = networkMonitor
    }

    /// Throws on simulator where Firebase Storage TLS connections fail.
    private func guardSimulator() throws {
        #if targetEnvironment(simulator)
        throw DocumentError.simulatorNotSupported
        #endif
    }

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
        try await networkMonitor.verifyReachable()
        try guardSimulator()
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
        try await networkMonitor.verifyReachable()
        try guardSimulator()
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let reference = storage.reference()
            .child("users/\(userId.uuidString)/avatar.jpg")
        _ = try await reference.putDataAsync(data, metadata: metadata)
        let url = try await reference.downloadURL()
        return url.absoluteString
    }

    /// Downloads image bytes from a download URL via URLSession (works on simulator, unlike the Storage SDK).
    /// - Parameter urlString: The download URL of the image.
    /// - Returns: The downloaded bytes.
    func downloadImageData(urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }

    /// Deletes a document from Firebase Storage by its download URL.
    /// An already-absent file counts as success, so retries after a partial failure are safe.
    /// - Parameter urlString: The download URL of the document to delete.
    func deleteDocument(urlString: String) async throws {
        try await networkMonitor.verifyReachable()
        let reference = storage.reference(forURL: urlString)
        do {
            try await reference.delete()
        } catch {
            let nsError = error as NSError
            guard nsError.domain == StorageErrorDomain,
                  nsError.code == StorageErrorCode.objectNotFound.rawValue else { throw error }
        }
    }

    /// Deletes every file under the user's Storage folder (`users/{userId}/`), recursively.
    /// Used on account deletion so no attachment or avatar is left behind, independently of the
    /// Firestore records. Retries are safe — a fresh listing only returns the remaining files.
    func deleteAllUserFiles(userId: UUID) async throws {
        #if targetEnvironment(simulator)
        return  // No Storage files on the simulator (uploads are blocked); nothing to delete.
        #else
        try await networkMonitor.verifyReachable()
        try await deleteAll(at: storage.reference().child("users/\(userId.uuidString)"))
        #endif
    }

    #if !targetEnvironment(simulator)
    /// Recursively deletes every item under a Storage reference, descending into subfolders.
    private func deleteAll(at reference: StorageReference) async throws {
        let result = try await reference.listAll()
        for item in result.items {
            try await item.delete()
        }
        for prefix in result.prefixes {
            try await deleteAll(at: prefix)
        }
    }
    #endif
}
