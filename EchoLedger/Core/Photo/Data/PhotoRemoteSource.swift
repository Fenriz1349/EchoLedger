//
//  PhotoRemoteSource.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation
import FirebaseStorage

/// Handles all Firebase Storage read and write operations for photos.
/// Photos are always remote — no local cache.
final class PhotoRemoteSource {

    private let storage = Storage.storage()

    /// Uploads a transaction photo and returns its download URL.
    /// - Parameters:
    ///   - data: The image data to upload.
    ///   - userId: The identifier of the owning user.
    ///   - transactionId: The identifier of the transaction this photo belongs to.
    /// - Returns: The download URL string for the uploaded photo.
    func uploadTransactionPhoto(_ data: Data, userId: UUID, transactionId: UUID) async throws -> String {
        let reference = storage.reference()
            .child("users/\(userId.uuidString)/transactions/\(transactionId.uuidString)")
        _ = try await reference.putDataAsync(data)
        let url = try await reference.downloadURL()
        return url.absoluteString
    }

    /// Uploads an avatar photo for a user and returns its download URL.
    /// - Parameters:
    ///   - data: The image data to upload.
    ///   - userId: The identifier of the owning user.
    /// - Returns: The download URL string for the uploaded avatar.
    func uploadAvatarPhoto(_ data: Data, userId: UUID) async throws -> String {
        let reference = storage.reference()
            .child("users/\(userId.uuidString)/avatar")
        _ = try await reference.putDataAsync(data)
        let url = try await reference.downloadURL()
        return url.absoluteString
    }

    /// Deletes a photo from Firebase Storage by its download URL.
    /// - Parameter urlString: The download URL of the photo to delete.
    func deletePhoto(urlString: String) async throws {
        let reference = storage.reference(forURL: urlString)
        try await reference.delete()
    }
}
