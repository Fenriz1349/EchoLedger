//
//  PieChartAnimator.swift
//  EchoLedger
//
//  Created by Julien Cotte on 25/06/2026.
//

import SwiftUI

/// Controls the progressive reveal of pie chart slices with a staggered animation.
/// Each slice's progress ramps to 1.0 sequentially after a configurable delay.
@Observable
final class PieChartAnimator {

    var progress: [Double] = []

    private var task: Task<Void, Never>?

    /// Cancels any in-flight reveal and starts a new one, animating each slice's progress to 1.0 in sequence.
    /// - Parameters:
    ///   - count: Number of slices to reveal.
    ///   - delay: Time between two consecutive slice reveals.
    ///   - animation: The animation applied to each slice's progress change.
    func start(for count: Int, delay: Double = 0.12, animation: Animation = .easeOut(duration: 0.6)) {
        task?.cancel()

        progress = Array(repeating: 0, count: count)

        task = Task {
            for index in 0..<count {

                try? await Task.sleep(
                    nanoseconds: UInt64(delay * 1_000_000_000)
                )

                await MainActor.run {
                    withAnimation(animation) {
                        progress[index] = 1.0
                    }
                }
            }
        }
    }

    /// Cancels any in-flight reveal and clears the progress so the chart can be re-animated from scratch.
    func reset() {
        task?.cancel()
        task = nil
        progress = []
    }
}
