//
//  DocumentDisplayView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 05/06/2026.
//

import SwiftUI

/// Displays a transaction attachment from a DocumentResult.
/// Image attachments are loaded remotely; PDFs and load failures fall back to the placeholder.
struct DocumentDisplayView: View {

    let document: DocumentResult
    @State private var showDocument = false

    var body: some View {
        if let urlString = document.urlString, let url = URL(string: urlString) {
            Button {
                showDocument = true
            } label: {
                if document.attachmentType == .image {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            EchoLedgerLoader()
                                .frame(width: 40, height: 40)
                                .frame(maxWidth: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        default:
                            document.placeholder.placeholderView
                                .frame(maxHeight: 80)
                        }
                    }
                } else {
                    document.placeholder.placeholderView
                        .frame(maxHeight: 80)
                }
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showDocument) {
                SafariDocumentView(url: url)
            }
        }
    }
}

#Preview("Image") {
    DocumentDisplayView(
        document: DocumentResult(
            urlString: "https://picsum.photos/300",
            attachmentType: .image,
            placeholder: .photo
        )
    )
}

#Preview("PDF") {
    DocumentDisplayView(
        document: DocumentResult(
            urlString: "https://example.com/file.pdf",
            attachmentType: .pdf,
            placeholder: .document
        )
    )
}
