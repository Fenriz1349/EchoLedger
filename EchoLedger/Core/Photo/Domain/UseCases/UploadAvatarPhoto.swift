//
//  UploadAvatarPhoto.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Uploads an avatar photo for the current user, stores it in Firebase Storage,
/// and updates the user's photoURL in the repository.
final class UploadAvatarPhoto {

    private let photoSource: PhotoRemoteSource
    private let userRepository: UserProviding
    private let userId: UUID

    init(photoSource: PhotoRemoteSource,
         userRepository: UserProviding,
         userId: UUID) {
        self.photoSource = photoSource
        self.userRepository = userRepository
        self.userId = userId
    }

    /// - Parameter data: The image data to upload.
    /// - Returns: The download URL string of the uploaded avatar.
    func execute(data: Data) async throws -> String {
        let url = try await photoSource.uploadAvatarPhoto(data, userId: userId)
        let currentUser = try await userRepository.fetchCurrent()
        let updated = User(
            id: currentUser.id,
            displayName: currentUser.displayName,
            email: currentUser.email,
            photoURL: url
        )
        try await userRepository.update(updated)
        return url
    }
}
