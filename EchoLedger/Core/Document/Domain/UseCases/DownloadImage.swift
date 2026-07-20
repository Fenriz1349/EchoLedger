//
//  DownloadImage.swift
//  EchoLedger
//
//  Created by Julien Cotte on 18/06/2026.
//

import Foundation

/// Downloads image bytes from a URL, best-effort: returns `nil` when offline or on failure
/// (callers fall back to a placeholder). Returns `Data` to keep the domain UIKit-free.
final class DownloadImage {

    private let documentSource: DocumentSourcing
    private let networkMonitor: NetworkMonitor

    init(documentSource: DocumentSourcing, networkMonitor: NetworkMonitor) {
        self.documentSource = documentSource
        self.networkMonitor = networkMonitor
    }

    /// - Parameter urlString: The remote download URL of the image.
    /// - Returns: The raw image data, or `nil` if offline or the download fails.
    func execute(urlString: String) async -> Data? {
        guard networkMonitor.isConnected else { return nil }
        return try? await documentSource.downloadImageData(urlString: urlString)
    }
}
