//
//  DocumentResult.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// The placeholder to display when no document URL is available or loading fails.
enum DocumentPlaceholder {
    /// Silhouette icon for user avatars.
    case avatar
    /// Document/receipt icon for transaction attachments.
    case document
}

/// Carries all the information a view needs to display a photo or document.
struct DocumentResult {
    /// The remote URL string of the attachment. Nil if no attachment exists.
    let urlString: String?
    /// The attachment type inferred from the MIME type. Nil for user avatars.
    let attachmentType: AttachmentType?
    /// The placeholder to show when urlString is nil or loading fails.
    let placeholder: DocumentPlaceholder
}
