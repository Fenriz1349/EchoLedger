//
//  DocumentPlaceholder+View.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import SwiftUI

/// Maps each DocumentPlaceholder case to its visual representation.
/// Single source of truth for placeholder images across the app.
extension DocumentPlaceholder {

    @ViewBuilder
    var placeholderView: some View {
        switch self {
        case .avatar:
            Image("avatarPlaceholder")
                .resizable()
                .scaledToFit()
        case .photo:
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.secondary)
        case .document:
            Image(systemName: "doc.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.secondary)
        }
    }
}
