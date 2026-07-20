//
//  CameraPickerView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import SwiftUI
import UIKit

/// Wraps UIImagePickerController to access the device camera.
/// Non disponible sur simulateur — protégé par UIImagePickerController.isSourceTypeAvailable(.camera).
/// Compresse la photo capturée en JPEG avant d'appeler onImageSelected.
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

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        private let parent: CameraPickerView

        init(parent: CameraPickerView) {
            self.parent = parent
        }

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
