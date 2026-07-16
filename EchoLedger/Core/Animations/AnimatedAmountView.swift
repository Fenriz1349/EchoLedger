//
//  AnimatedAmountView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 25/06/2026.
//

import SwiftUI

/// Displays a euro amount that counts up from 0 to `value` on appear (and re-counts when `value`changes).
/// The caller sets the font/colour. Reused for account balances, the user's total balance, detail screens…
struct AnimatedAmountView: View {

    let value: Double
    var color: Color? = nil
    var duration: Double = 0.8

    @State private var animated: Double = 0

    var body: some View {
        CountingAmountText(value: animated)
            .foregroundStyle(color ?? value.balanceColor)
            .onAppear {
                withAnimation(.easeOut(duration: duration)) { animated = value }
            }
            .onChange(of: value) { _, newValue in
                withAnimation(.easeOut(duration: duration)) { animated = newValue }
            }
    }
}

/// An `Animatable` text whose `Double` is interpolated frame-by-frame, producing the counting effect.
/// `monospacedDigit` keeps the width stable so the digits don't jitter horizontally while counting.
private struct CountingAmountText: View, Animatable {

    var value: Double

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text(value.toEuro)
            .monospacedDigit()
    }
}

#Preview {
    AnimatedAmountView(value: 1250.50)
        .font(.title2.weight(.semibold))
}
