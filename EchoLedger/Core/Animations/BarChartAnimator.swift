//
//  BarChartAnimator.swift
//  EchoLedger
//
//  Created by Julien Cotte on 25/06/2026.
//

import SwiftUI

/// Controls the progressive reveal of chart data points with a staggered animation.
/// Each item becomes visible sequentially after a configurable delay.
@Observable
final class BarChartAnimator {

    var visibleItems = 0

    /// Reveals items one by one, incrementing `visibleItems` on a timer so each bar animates in after the previous one.
    /// - Parameters:
    ///   - count: Total number of items to reveal.
    ///   - delay: Time between two consecutive reveals.
    func start(for count: Int, delay: Double = 0.1) {
        visibleItems = 0

        for index in 0..<count {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + Double(index) * delay
            ) {
                withAnimation(.easeOut(duration: 0.8)) {
                    self.visibleItems = index + 1
                }
            }
        }
    }
}
