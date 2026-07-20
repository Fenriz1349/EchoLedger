//
//  SuccessCheckmarkView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 20/07/2026.
//

import SwiftUI

/// A "+" that rises from the FAB's position to the screen's center, morphs into a green
/// checkmark, then fades out — a success confirmation shown after adding a transaction.
struct SuccessCheckmarkView: View {

    @Binding var isPresented: Bool

    @State private var isAtCenter = false
    @State private var isChecked = false
    @State private var symbolName = "plus"
    @State private var opacity: Double = 1
    @State private var checkScale: CGFloat = 1

    var body: some View {
        GeometryReader { proxy in
            if isPresented {
                Image(systemName: symbolName)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(isChecked ? Color.green : Color.accentColor)
                    .contentTransition(.symbolEffect(.replace.byLayer))
                    .scaleEffect(checkScale)
                    .frame(width: 52, height: 52)
                    .opacity(opacity)
                    .position(
                        x: proxy.size.width / 2,
                        y: isAtCenter ? proxy.size.height / 2 : proxy.size.height - 80
                    )
                    .onAppear { animateSequence() }
            }
        }
        .allowsHitTesting(false)
    }
    /// Runs the full choreography in order: rise to center, morph to checkmark, pop, then fade out.
    private func animateSequence() {
        withAnimation(.spring(duration: 0.5)) {
            isAtCenter = true
        }
        Task {
            try? await Task.sleep(for: .seconds(0.5))
            withAnimation(.easeInOut(duration: 0.3)) {
                isChecked = true
                symbolName = "checkmark"
            }
            try? await Task.sleep(for: .seconds(0.3))
            withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) {
                checkScale = 1.6
            }
            try? await Task.sleep(for: .seconds(0.2))
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                checkScale = 1
            }
            try? await Task.sleep(for: .seconds(0.9))
            withAnimation(.easeInOut(duration: 0.4)) {
                opacity = 0
            }
            try? await Task.sleep(for: .seconds(0.4))
            isPresented = false
            isAtCenter = false
            isChecked = false
            symbolName = "plus"
            opacity = 1
            checkScale = 1
        }
    }
}

#Preview {
    @Previewable @State var isPresented = false
    return VStack {
        Button("Rejouer") { isPresented = true }
        Spacer()
    }
    .overlay {
        SuccessCheckmarkView(isPresented: $isPresented)
    }
    .echoBackground()
}
