//
//  VisibilityObserver.swift
//  EchoLedger
//
//  Created by Julien Cotte on 25/06/2026.
//

import SwiftUI

/// Triggers a callback when the view becomes visible on screen.
/// Designed for ScrollView / Lazy stacks to avoid early `onAppear` triggers.
struct VisibilityObserver: ViewModifier {

    /// Called once when the view is first visible.
    let onVisible: () -> Void
    @State private var hasTriggered = false

    /// Wraps content with a clear GeometryReader that checks visibility on appear and on every frame change.
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            checkVisibility(proxy: proxy)
                        }
                        .onChange(of: proxy.frame(in: .global)) { _, _ in
                            checkVisibility(proxy: proxy)
                        }
                }
            )
    }

    /// Checks if the view is currently visible on screen.
    /// Fires `onVisible` only once.
    private func checkVisibility(proxy: GeometryProxy) {
        guard !hasTriggered else { return }

        let frame = proxy.frame(in: .global)
        let screenHeight = UIScreen.main.bounds.height

        let isVisible = frame.minY < screenHeight && frame.maxY > 0

        if isVisible {
            hasTriggered = true
            onVisible()
        }
    }
}
