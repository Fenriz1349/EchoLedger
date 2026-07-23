//
//  CameraPickerView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import SwiftUI
import UIKit

/// Wraps UIImagePickerController to access the device camera.
/// Not available on simulator — guarded by UIImagePickerController.isSourceTypeAvailable(.camera).
/// Compresses the captured photo to JPEG before calling onImageSelected.
struct CameraPickerView: UIViewControllerRepresentable {

    let onImageSelected: (Data) -> Void

    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    // MARK: - Coordinator

    /// Bridges UIImagePickerController's delegate callbacks back to the SwiftUI view.
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        private let parent: CameraPickerView

        init(parent: CameraPickerView) {
            self.parent = parent
        }

        /// Compresses the captured photo to JPEG, forwards it via onImageSelected, then dismisses.
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage,
               let jpegData = image.jpegData(compressionQuality: 0.8) {
                parent.onImageSelected(jpegData)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
