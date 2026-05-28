//
//  AvatarCircleView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import SwiftUI

/// Displays a circular avatar from a DocumentResult.
/// Shows the avatar placeholder immediately, replaced by the remote image on success.
struct AvatarCircleView: View {

    let document: DocumentResult
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(Color(.secondarySystemBackground))
            .overlay {
                if let urlString = document.urlString, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                        default:
                            document.placeholder.placeholderView
                                .padding(size * 0.08)
                        }
                    }
                } else {
                    document.placeholder.placeholderView
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
    AvatarCircleView(
        document: DocumentResult(urlString: nil, attachmentType: nil, placeholder: .avatar),
        size: 180
    )
}

#Preview("Avec photo") {
    AvatarCircleView(
        document: DocumentResult(
            urlString: "https://picsum.photos/200",
            attachmentType: nil,
            placeholder: .avatar
        ),
        size: 180
    )
}
