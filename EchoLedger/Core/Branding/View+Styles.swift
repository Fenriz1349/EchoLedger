//
//  View+Styles.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/06/2026.
//

import SwiftUI

/// The single definition of EchoLedger's list-row card: brand surface with a hairline border.
/// Specialised row backgrounds build on it (see `AccountRowBackground`).
struct EchoRowCard: View {

    var cornerRadius: CGFloat = 6

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius)
        shape
            .fill(Color.echoCard)
            .overlay(shape.strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5))
    }
}

extension View {

    /// EchoLedger's unified list-row card, applied as the row background.
    /// Pair it with `.cascadeRow(index:)` for the staggered entrance.
    /// - Parameter cornerRadius: The row's corner radius (lower = more rectangular).
    func echoRowStyle(cornerRadius: CGFloat = 6) -> some View {
        listRowBackground(EchoRowCard(cornerRadius: cornerRadius))
    }

    /// EchoLedger's brand-tinted screen background, edge to edge.
    /// Hides the default list/scroll background so the row cards sit on the brand surface.
    /// Apply after `refreshable`/`searchable` so those stay attached to the scroll view.
    func echoBackground() -> some View {
        ZStack {
            Color.echoBackground.ignoresSafeArea()
            self.scrollContentBackground(.hidden)
        }
    }
}

extension CGFloat {

    /// EchoLedger's standard corner radius for fields and inner cards.
    static let echoCorner: CGFloat = 12
}
