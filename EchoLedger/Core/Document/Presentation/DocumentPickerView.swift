//
//  DocumentPickerView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 05/06/2026.
//

import SwiftUI
import UniformTypeIdentifiers

/// UIKit wrapper for selecting a PDF file from the device.
struct DocumentPickerView: UIViewControllerRepresentable {

    let onDocumentSelected: (Data) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDocumentSelected: onDocumentSelected, dismiss: dismiss)
    }

    /// Bridges UIDocumentPickerViewController's delegate callbacks back to the SwiftUI view.
    final class Coordinator: NSObject, UIDocumentPickerDelegate {

        let onDocumentSelected: (Data) -> Void
        let dismiss: DismissAction

        init(onDocumentSelected: @escaping (Data) -> Void, dismiss: DismissAction) {
            self.onDocumentSelected = onDocumentSelected
            self.dismiss = dismiss
        }

        /// Reads the picked file through its security-scoped resource and forwards the raw data.
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first,
                  url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            guard let data = try? Data(contentsOf: url) else { return }
            onDocumentSelected(data)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            dismiss()
        }
    }
}
