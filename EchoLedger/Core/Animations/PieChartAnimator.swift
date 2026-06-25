//
//  PieChartAnimator.swift
//  EchoLedger
//
//  Created by Julien Cotte on 25/06/2026.
//

import SwiftUI

@Observable
final class PieChartAnimator {

    var visibleSlices: Int = 0

    private var task: Task<Void, Never>?

    func start(
        count: Int,
        delay: Double = 0.12,
        animation: Animation = .easeOut(duration: 0.6)
    ) {
        task?.cancel()

        visibleSlices = 0

        task = Task {
            for index in 0..<count {
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

                await MainActor.run {
                    withAnimation(animation) {
                        visibleSlices = index + 1
                    }
                }
            }
        }
    }

    func reset() {
        task?.cancel()
        task = nil
        visibleSlices = 0
    }
}
