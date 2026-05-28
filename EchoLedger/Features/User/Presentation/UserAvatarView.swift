//
//  UserAvatarView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import SwiftUI
import PhotosUI

/// Circular avatar with an edit button overlay.
/// Composes AvatarCircleView and AvatarEditButtonView.
/// Manages the image source picker (camera or library) and delegates data to onImageSelected.
struct UserAvatarView: View {

    let document: DocumentResult
    let size: CGFloat
    let onImageSelected: (Data) -> Void
    let onRemove: (() -> Void)?

    @State private var showOptions = false
    @State private var showCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AvatarCircleView(document: document, size: size)

            AvatarEditButtonView(size: size, onTap: { showOptions = true })
                .offset(x: 6, y: 6)
        }
        .confirmationDialog("Photo de profil", isPresented: $showOptions) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Prendre une photo") { showCamera = true }
            }
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Text("Choisir dans la bibliothèque")
            }
            if onRemove != nil {
                Button("Supprimer la photo", role: .destructive) { onRemove?() }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPickerView(onImageSelected: onImageSelected)
        }
        .onChange(of: selectedPhotoItem) { _, item in
            Task {
                guard let rawData = try? await item?.loadTransferable(type: Data.self),
                      let image = UIImage(data: rawData),
                      let jpegData = image.jpegData(compressionQuality: 0.8) else { return }
                onImageSelected(jpegData)
            }
        }
    }
}

#Preview {
    UserAvatarView(
        document: DocumentResult(urlString: nil, attachmentType: nil, placeholder: .avatar),
        size: 180,
        onImageSelected: { _ in },
        onRemove: {}
    )
}
