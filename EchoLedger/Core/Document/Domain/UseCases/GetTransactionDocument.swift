//
//  GetTransactionDocument.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import Foundation

/// Returns the document result for a transaction attachment.
/// Maps the standard MIME contentType to AttachmentType for rendering.
/// Always uses the document placeholder regardless of attachment type.
final class GetTransactionDocument {

    func execute(transaction: Transaction) -> DocumentResult {
        let attachmentType: AttachmentType? = transaction.attachmentContentType.map { mime in
            mime == "application/pdf" ? .pdf : .image
        }
        return DocumentResult(
            urlString: transaction.attachmentURL,
            attachmentType: attachmentType,
            placeholder: .document
        )
    }
}
