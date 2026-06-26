//
//  SwipeRow.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/06/2026.
//

import SwiftUI

/// Wraps a row with trailing swipe actions, reproducing native swipe-to-reveal inside a
/// `ScrollView`/`LazyVStack` where `.swipeActions` is a no-op. Owns the row tap.
struct SwipeRow<Content: View>: View {

    struct Action: Identifiable {
        let id = UUID()
        let label: String
        let systemImage: String
        let tint: Color
        let action: () -> Void
    }

    let actions: [Action]
    let onTap: () -> Void
    @ViewBuilder let content: () -> Content

    private let buttonSpacing: CGFloat = 8
    private let groupPadding: CGFloat = 10
    @State private var offset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    @State private var rowHeight: CGFloat = 0
    @State private var rowWidth: CGFloat = 0
    @State private var actionsWidth: CGFloat = 0

    private var revealWidth: CGFloat { actionsWidth }
    private var isOpen: Bool { offset < 0 }

    var body: some View {
        accessible(
            ZStack(alignment: .trailing) {
                if willDelete, let last = actions.last {
                    deleteCapsule(last)
                        .frame(width: max(0, -offset))
                } else {
                    HStack(spacing: buttonSpacing) {
                        ForEach(actions) { action in actionButton(action) }
                    }
                    .padding(.horizontal, groupPadding)
                    .frame(height: rowHeight)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear { actionsWidth = geo.size.width }
                                .onChange(of: geo.size.width) { _, width in actionsWidth = width }
                        }
                    )
                    .offset(x: max(0, revealWidth + offset))
                    .opacity(isOpen ? 1 : 0)
                }

                content()
                    .frame(maxWidth: .infinity)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear { rowHeight = geo.size.height; rowWidth = geo.size.width }
                                .onChange(of: geo.size) { _, size in
                                    rowHeight = size.height
                                    rowWidth = size.width
                                }
                        }
                    )
                    .contentShape(Rectangle())
                    .offset(x: offset)
                    .onTapGesture { isOpen ? close() : onTap() }
            }
            .clipped()
            .gesture(drag)
            .sensoryFeedback(trigger: willDelete) { _, entering in
                entering ? .impact(weight: .medium) : nil
            }
        )
    }

    /// Destructive capsule that fills the revealed area in delete mode, signalling release-to-delete.
    private func deleteCapsule(_ action: Action) -> some View {
        ZStack(alignment: .trailing) {
            Capsule().fill(action.tint)
            HStack(spacing: 6) {
                Image(systemName: action.systemImage)
                Text(action.label)
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
        }
        .frame(height: rowHeight)
    }

    private func actionButton(_ action: Action) -> some View {
        Button {
            close()
            action.action()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: action.systemImage)
                Text(action.label)
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .frame(height: rowHeight)
            .background(action.tint, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    /// Past this drag distance, releasing triggers the trailing action (full-swipe to delete).
    private var fullSwipeThreshold: CGFloat { rowWidth * 0.7 }

    /// True once the drag passes the threshold: the row switches to delete mode.
    private var willDelete: Bool { offset < -fullSwipeThreshold }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                guard abs(value.translation.width) > abs(value.translation.height) else { return }
                offset = min(0, max(lastOffset + value.translation.width, -rowWidth))
            }
            .onEnded { value in
                let proposed = lastOffset + value.translation.width
                if proposed < -fullSwipeThreshold, let last = actions.last {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { offset = -rowWidth }
                    lastOffset = 0
                    last.action()
                    return
                }
                let open = -offset > revealWidth / 2 || value.predictedEndTranslation.width < -revealWidth
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    offset = open ? -revealWidth : 0
                }
                lastOffset = offset
            }
    }

    private func close() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { offset = 0 }
        lastOffset = 0
    }

    /// Exposes each action to VoiceOver since the reveal gesture is invisible to it.
    private func accessible<V: View>(_ view: V) -> some View {
        actions.reduce(AnyView(view)) { partial, action in
            AnyView(partial.accessibilityAction(named: Text(action.label)) { action.action() })
        }
    }
}

#Preview {
    SwipeRow(
        actions: [
            .init(label: "Modifier", systemImage: "pencil", tint: .blue, action: {}),
            .init(label: "Supprimer", systemImage: "trash", tint: .red, action: {})
        ],
        onTap: {}
    ) {
        HStack {
            Text("Courses")
            Spacer()
            Text("-42,00 €")
        }
        .padding()
    }
    .echoRowStyle()
    .padding()
}
