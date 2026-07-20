//
//  PieCarouselPageIndicator.swift
//  EchoLedger
//
//  Created by Julien Cotte on 13/06/2026.
//

import SwiftUI

/// Dot-based page indicator for the monthly pie carousel.
/// The active dot expands into a capsule; inactive dots are dimmed circles.
/// - Parameters:
///   - count: Total number of pages.
///   - currentIndex: Index of the currently active page.
struct PieCarouselPageIndicator: View {

    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color.primary : Color.secondary.opacity(0.3))
                    .frame(width: index == currentIndex ? 16 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }
        }
    }
}

#Preview {
    PieCarouselPageIndicator(count: 6, currentIndex: 2)
        .padding()
}
