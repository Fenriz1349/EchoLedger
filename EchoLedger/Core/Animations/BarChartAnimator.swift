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

    func start(count: Int, delay: Double = 0.1) {
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
