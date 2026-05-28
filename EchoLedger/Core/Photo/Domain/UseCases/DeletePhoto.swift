//
//  DeletePhoto.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Deletes a photo from Firebase Storage by its download URL.
final class DeletePhoto {

    private let photoSource: PhotoRemoteSource

    init(photoSource: PhotoRemoteSource) {
        self.photoSource = photoSource
    }

    /// - Parameter urlString: The download URL of the photo to delete.
    func execute(urlString: String) async throws {
        try await photoSource.deletePhoto(urlString: urlString)
    }
}
