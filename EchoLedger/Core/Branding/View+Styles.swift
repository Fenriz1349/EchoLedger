//
//  View+Styles.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/06/2026.
//

import SwiftUI

extension View {

    /// EchoLedger's unified list-row look: tight insets, rounded background and no separator.
    /// Pair it with `.cascadeRow(index:)` for the staggered entrance.
    /// - Parameter cornerRadius: The row's corner radius (lower = more rectangular).
    func echoRowStyle(cornerRadius: CGFloat = 6) -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color("RowBackgroundColor"))
                    .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
            )
    }

    /// EchoLedger's brand-tinted screen background, edge to edge.
    /// Hides the default list/scroll background so cards (`echoRowStyle`) sit on the brand surface.
    /// Apply after `refreshable`/`searchable` so those stay attached to the scroll view.
    func echoBackground() -> some View {
        ZStack {
            Color("BackgroundColor").ignoresSafeArea()
            self.scrollContentBackground(.hidden)
        }
    }
}
