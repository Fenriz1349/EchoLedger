//
//  DocumentPickerSection.swift
//  EchoLedger
//
//  Created by Julien Cotte on 05/06/2026.
//

import SwiftUI
import PhotosUI

/// Reusable picker logic for selecting a photo (camera or gallery) or a PDF file.
/// Exposes a binding `showOptions` that the parent triggers from its own button.
/// Attaches the confirmation dialog, camera sheet, photos picker, and document picker.
struct DocumentPickerSection: ViewModifier {

    @Binding var showOptions: Bool
    let allowsPDF: Bool
    let onImageSelected: (Data) -> Void
    let onPDFSelected: ((Data) -> Void)?
    let onRemove: (() -> Void)?

    @State private var showCamera = false
    @State private var showPhotosPicker = false
    @State private var showDocumentPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    func body(content: Content) -> some View {
        content
            .confirmationDialog("Ajouter un document", isPresented: $showOptions) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Prendre une photo") { showCamera = true }
                }
                Button("Choisir dans la bibliothèque") { showPhotosPicker = true }
                if allowsPDF {
                    Button("Sélectionner un PDF") { showDocumentPicker = true }
                }
                if onRemove != nil {
                    Button("Supprimer", role: .destructive) { onRemove?() }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraPickerView(onImageSelected: onImageSelected)
            }
            .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { _, item in
                Task {
                    guard let rawData = try? await item?.loadTransferable(type: Data.self),
                          let image = UIImage(data: rawData),
                          let jpegData = image.jpegData(compressionQuality: 0.8) else { return }
                    selectedPhotoItem = nil
                    onImageSelected(jpegData)
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPickerView { data in
                    onPDFSelected?(data)
                }
            }
    }
}

extension View {
    /// Attaches the document picker logic to any view.
    /// Toggle `showOptions` from your own button to open the confirmation dialog.
    func documentPicker(
        showOptions: Binding<Bool>,
        allowsPDF: Bool = false,
        onImageSelected: @escaping (Data) -> Void,
        onPDFSelected: ((Data) -> Void)? = nil,
        onRemove: (() -> Void)? = nil
    ) -> some View {
        modifier(DocumentPickerSection(
            showOptions: showOptions,
            allowsPDF: allowsPDF,
            onImageSelected: onImageSelected,
            onPDFSelected: onPDFSelected,
            onRemove: onRemove
        ))
    }
}
