//
//  EchoLedgerLoader.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/04/2026.
//

import SwiftUI

/// Animated logo mark: bars reveal one by one, then loop as a continuous sine wave.
struct EchoLedgerLoader: View {

    /// Bar heights (relative to maxBarHeight) and colors, left to right.
    private let bars: [(heightRatio: CGFloat, color: Color)] = [
        (0.38, Color(hex: "#3D2060")),
        (0.58, Color(hex: "#4E2A7A")),
        (0.77, Color(hex: "#6538A0")),
        (1.00, Color(hex: "#8B50CC")),
        (0.80, Color(hex: "#A06AE0")),
        (0.61, Color(hex: "#B880F0")),
        (0.45, Color(hex: "#C898FA")),
        (0.32, Color(hex: "#D4AAFF")),
        (0.23, Color(hex: "#D4AAFF"))
    ]

    @State private var barVisible: [Bool] = Array(repeating: false, count: 9)
    @State private var waveStart: Date?

    var body: some View {
        // TimelineView is paused during the reveal phase to avoid unnecessary redraws
        TimelineView(.animation(minimumInterval: 1 / 60, paused: waveStart == nil)) { timeline in
            GeometryReader { proxy in
                let maxBarHeight = proxy.size.height * 0.44
                // 9 bars + 8 gaps + 1 margin slot on each side = 19 slots total
                let barWidth = proxy.size.width / CGFloat(bars.count * 2 + 1)
                let elapsed = waveStart.map { timeline.date.timeIntervalSince($0) } ?? 0

                ZStack {
                    RoundedRectangle(cornerRadius: proxy.size.width * 0.22)
                        .fill(Color(hex: "#120D1F"))

                    HStack(spacing: barWidth) {
                        ForEach(bars.indices, id: \.self) { barIndex in
                            let baseHeight = maxBarHeight * bars[barIndex].heightRatio
                            // Wave factor: oscillates between 0.65 and 1.0 with per-bar phase offset
                            let waveFactor = waveStart != nil
                                ? 0.65 + 0.35 * sin(elapsed * 2.5 + Double(barIndex) * 0.7)
                                : 1.0
                            let currentHeight = barVisible[barIndex] ? baseHeight * waveFactor : 0
                            let barColor = bars[barIndex].color

                            VStack(spacing: 0) {
                                // Main bar anchored at bottom, grows upward
                                Capsule()
                                    .fill(barColor)
                                    .frame(width: barWidth, height: currentHeight)
                                    .frame(width: barWidth, height: maxBarHeight, alignment: .bottom)

                                // Reflection anchored at top, grows downward
                                Capsule()
                                    .fill(barColor.opacity(0.28))
                                    .frame(width: barWidth, height: currentHeight)
                                    .frame(width: barWidth, height: maxBarHeight, alignment: .top)
                            }
                        }
                    }
                }
            }
        }
        .onAppear { startAnimation() }
    }

    /// Reveals bars one by one with a spring, then starts the infinite sine wave.
    private func startAnimation() {
        barVisible = Array(repeating: false, count: bars.count)
        waveStart = nil

        for barIndex in bars.indices {
            withAnimation(
                .spring(response: 0.35, dampingFraction: 0.65)
                .delay(Double(barIndex) * 0.08)
            ) {
                barVisible[barIndex] = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(bars.count) * 0.08 + 0.5) {
            waveStart = Date()
        }
    }
}

#Preview {
    EchoLedgerLoader()
        .frame(width: 120, height: 120)
}
