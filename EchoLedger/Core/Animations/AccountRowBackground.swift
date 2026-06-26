//
//  AccountRowBackground.swift
//  EchoLedger
//
//  Created by Julien Cotte on 25/06/2026.
//

import SwiftUI

/// Full-cell background for an account row: the rounded card plus a proportional bar (the account's
/// share of its sign group) that grows in on appear, staggered by row position. Used via
/// `.listRowBackground(...)` so it fills the whole cell, edge to edge.
struct AccountRowBackground: View {

    let percentage: Double
    let color: Color
    var index: Int = 0
    var cornerRadius: CGFloat = 6

    @State private var barFraction: CGFloat = 0

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius)
        shape
            .fill(Color("CardBackgroundColor"))
            .overlay(alignment: .leading) {
                GeometryReader { geo in
                    Rectangle()
                        .fill(color.opacity(0.18))
                        .frame(width: barFraction * geo.size.width)
                }
            }
            .clipShape(shape)
            .overlay(
                shape.strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
            )
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(Double(index) * 0.08)) {
                    barFraction = percentage
                }
            }
            .onChange(of: percentage) { _, newValue in
                withAnimation(.easeOut(duration: 0.6)) {
                    barFraction = newValue
                }
            }
    }
}

#Preview {
    AccountRowBackground(percentage: 100, color: .green)
}
