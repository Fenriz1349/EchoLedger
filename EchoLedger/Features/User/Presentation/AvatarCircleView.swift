//
//  AvatarCircleView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import SwiftUI
import UIKit

/// Displays a circular avatar from already-downloaded image bytes.
/// Shows the avatar placeholder when there is no image (none set, offline, or load failed).
/// The `Data → UIImage` bridge is the single point where UIKit enters the avatar flow.
struct AvatarCircleView: View {

    let imageData: Data?
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(Color(.secondarySystemBackground))
            .overlay {
                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                } else {
                    DocumentPlaceholder.avatar.placeholderView
                        .padding(size * 0.08)
                }
            }
            .overlay {
                Circle()
                    .stroke(Color.accentColor.opacity(0.8), lineWidth: 2)
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}

#Preview("Sans photo") {
    AvatarCircleView(imageData: nil, size: 180)
}
