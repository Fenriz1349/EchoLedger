//
//  AvatarEditButtonView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import SwiftUI

/// Small circular pencil button overlaid at the bottom-right of the avatar.
struct AvatarEditButtonView: View {

    let size: CGFloat
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "pencil")
                .font(.system(size: size * 0.16, weight: .semibold))
                .foregroundStyle(.accent)
                .frame(width: size * 0.26, height: size * 0.26)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 1.5)
                }
        }
    }
}

#Preview {
    AvatarEditButtonView(size: 180, onTap: {})
}
