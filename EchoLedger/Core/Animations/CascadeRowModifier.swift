//
//  CascadeRowModifier.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/06/2026.
//

import SwiftUI

/// Staircase entrance for list rows: each row slides in from the left with a fade, staggered by its
/// position, so the list reveals itself in cascade. Works inside `List` (unlike `.scrollTransition`).
struct CascadeRowModifier: ViewModifier {

    let index: Int

    @State private var appeared = false

    /// Delay between two consecutive rows (the "staircase" step). Tune to taste.
    private let staggerStep = 0.08
    /// Caps the stagger so rows far down the list don't wait an absurd amount.
    private let maxStaggeredRows = 12
    /// How far to the left the row starts before sliding into place.
    private let slideDistance: CGFloat = 120

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(x: appeared ? 0 : -slideDistance)
            .animation(.easeOut(duration: 0.35).delay(delay()), value: appeared)
            .modifier(
                VisibilityObserver {
                    appeared = true
                }
            )
    }

    private func delay() -> Double {
            Double(min(index, maxStaggeredRows)) * staggerStep
        }
}

extension View {

    /// Reveals a list row with a staggered left-to-right slide based on its position in the list.
    /// - Parameter index: The row's position; drives the staircase delay.
    func cascadeRow(index: Int) -> some View {
        modifier(CascadeRowModifier(index: index))
    }
}
