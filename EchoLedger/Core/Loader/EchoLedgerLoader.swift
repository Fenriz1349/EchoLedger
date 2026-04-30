//
//  EchoLedgerLoader.swift
//  EchoLedger
//
//  Created by Julien Cotte on 30/04/2026.
//

import SwiftUI

struct EchoLedgerLoader: View {

    private let bars: [(height: CGFloat, color: Color)] = [
        (0.38, Color(hex: "#3D2060")),
        (0.58, Color(hex: "#4E2A7A")),
        (0.77, Color(hex: "#6538A0")),
        (1.00, Color(hex: "#8B50CC")),
        (0.80, Color(hex: "#A06AE0")),
        (0.61, Color(hex: "#B880F0")),
        (0.45, Color(hex: "#C898FA")),
        (0.32, Color(hex: "#D4AAFF")),
        (0.23, Color(hex: "#D4AAFF")),
    ]

    @State private var visible: [Bool] = Array(repeating: false, count: 9)

    var body: some View {
        GeometryReader { geo in
            let maxH = geo.size.height * 0.45
            let barW = geo.size.width / CGFloat(bars.count * 2 - 1)
            let axisY = geo.size.height / 2

            ZStack {
                RoundedRectangle(cornerRadius: geo.size.width * 0.22)
                    .fill(Color(hex: "#120D1F"))

                HStack(spacing: barW) {
                    ForEach(bars.indices, id: \.self) { i in
                        let h = maxH * bars[i].height
                        let col = bars[i].color

                        VStack(spacing: 0) {
                            // Barre haute
                            Capsule()
                                .fill(col)
                                .frame(width: barW, height: visible[i] ? h : 0)

                            // Barre basse (reflet)
                            Capsule()
                                .fill(col.opacity(0.28))
                                .frame(width: barW, height: visible[i] ? h : 0)
                        }
                        .frame(height: maxH * 2, alignment: .center)
                    }
                }
                .padding(.horizontal, barW)
            }
        }
        .onAppear { startAnimation() }
    }

    func startAnimation() {
        visible = Array(repeating: false, count: bars.count)

        for i in bars.indices {
            withAnimation(
                .spring(response: 0.35, dampingFraction: 0.65)
                .delay(Double(i) * 0.08)
            ) {
                visible[i] = true
            }
        }
    }
}

#Preview {
    EchoLedgerLoader()
}
