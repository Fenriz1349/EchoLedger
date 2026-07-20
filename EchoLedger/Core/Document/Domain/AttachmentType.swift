//
//  AttachmentType.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Describes the type of attachment stored for a transaction.
/// Used to determine how to render the attachment in the UI (AsyncImage vs PDFView).
enum AttachmentType: String, Codable, Equatable {
    case image
    case pdf
}
