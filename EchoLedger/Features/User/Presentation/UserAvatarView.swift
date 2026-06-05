//
//  UserAvatarView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import SwiftUI

/// Circular avatar with an edit button overlay.
/// Composes AvatarCircleView and AvatarEditButtonView.
/// Uses DocumentPickerSection for the image source selection.
struct UserAvatarView: View {

    let document: DocumentResult
    let size: CGFloat
    let onImageSelected: (Data) -> Void
    let onRemove: (() -> Void)?
    let onEditBlocked: (() -> Void)?

    @State private var showOptions = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AvatarCircleView(document: document, size: size)

            AvatarEditButtonView(size: size, onTap: {
                if let onEditBlocked {
                    onEditBlocked()
                } else {
                    showOptions = true
                }
            })
            .offset(x: 6, y: 6)
        }
        .documentPicker(
            showOptions: $showOptions,
            onImageSelected: onImageSelected,
            onRemove: onRemove
        )
    }
}

#Preview {
    UserAvatarView(
        document: DocumentResult(urlString: nil, attachmentType: nil, placeholder: .avatar),
        size: 180,
        onImageSelected: { _ in },
        onRemove: {},
        onEditBlocked: nil
    )
}
