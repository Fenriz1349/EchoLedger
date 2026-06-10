//
//  TransactionAttachmentSection.swift
//  EchoLedger
//
//  Created by Julien Cotte on 05/06/2026.
//

import SwiftUI
import UIKit

/// Lets the user attach an optional photo or PDF to a transaction being created.
struct TransactionAttachmentSection: View {

    @Bindable var viewModel: TransactionFormViewModel
    @State private var showOptions = false
    @State private var previewImage: UIImage?

    var body: some View {
        Section("Justificatif") {
            if viewModel.isAnonymous {
                Text("Disponible avec un compte permanent")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            } else if viewModel.selectedAttachmentData != nil {
                if viewModel.selectedAttachmentType == .image {
                    if let previewImage {
                        Image(uiImage: previewImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                } else {
                    Label("Document PDF sélectionné", systemImage: "doc.fill")
                        .foregroundStyle(.secondary)
                }
                Button("Supprimer le justificatif", role: .destructive) {
                    viewModel.clearAttachment()
                }
            } else {
                if let existingDocument = viewModel.existingDocument {
                    DocumentDisplayView(document: existingDocument)
                }
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    if DocumentError.isSimulator {
                        viewModel.showSimulatorWarning()
                    } else {
                        showOptions = true
                    }
                } label: {
                    Label(
                        viewModel.existingDocument == nil ? "Ajouter une photo ou un PDF" : "Remplacer le justificatif",
                        systemImage: viewModel.existingDocument == nil ? "paperclip" : "arrow.triangle.2.circlepath"
                    )
                }
                .documentPicker(
                    showOptions: $showOptions,
                    allowsPDF: true,
                    onImageSelected: { viewModel.selectAttachment(data: $0, type: .image) },
                    onPDFSelected: { viewModel.selectAttachment(data: $0, type: .pdf) }
                )
            }
        }
        .task(id: viewModel.selectedAttachmentData) {
            if viewModel.selectedAttachmentType == .image, let data = viewModel.selectedAttachmentData {
                previewImage = UIImage(data: data)
            } else {
                previewImage = nil
            }
        }
    }
}

#Preview {
    Form {
        TransactionAttachmentSection(viewModel: PreviewHelpers.makeTransactionFormViewModel())
    }
}
