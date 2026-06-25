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
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            .listRowBackground(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .listRowSeparator(.hidden)
    }
}
