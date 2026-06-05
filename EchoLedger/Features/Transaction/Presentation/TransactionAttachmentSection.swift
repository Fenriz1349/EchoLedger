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

    var body: some View {
        Section("Justificatif") {
            if viewModel.isAnonymous {
                Text("Disponible avec un compte permanent")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            } else if let data = viewModel.selectedAttachmentData {
                if viewModel.selectedAttachmentType == .image, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Label("Document PDF sélectionné", systemImage: "doc.fill")
                        .foregroundStyle(.secondary)
                }
                Button("Supprimer le justificatif", role: .destructive) {
                    viewModel.clearAttachment()
                }
            } else {
                Button {
                    if DocumentError.isSimulator {
                        viewModel.showSimulatorWarning()
                    } else {
                        showOptions = true
                    }
                } label: {
                    Label("Ajouter une photo ou un PDF", systemImage: "paperclip")
                }
                .documentPicker(
                    showOptions: $showOptions,
                    allowsPDF: true,
                    onImageSelected: { viewModel.selectAttachment(data: $0, type: .image) },
                    onPDFSelected: { viewModel.selectAttachment(data: $0, type: .pdf) }
                )
            }
        }
    }
}

#Preview {
    Form {
        TransactionAttachmentSection(viewModel: PreviewHelpers.makeTransactionFormViewModel())
    }
}
