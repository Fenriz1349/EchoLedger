//
//  SegmentedToggle.swift
//  EchoLedger
//
//  Created by Julien Cotte on 25/06/2026.
//

import SwiftUI

/// Two-option segmented control bound to a Bool, styled per use case.
/// Fills the active segment with its meaning color (a nil side keeps a neutral thumb).
struct SegmentedToggle: View {

    enum Style {
        case transaction
        case account

        var falseLabel: String {
            switch self {
            case .transaction: "Dépense"
            case .account: "Positif"
            }
        }

        var trueLabel: String {
            switch self {
            case .transaction: "Revenue"
            case .account: "Négatif"
            }
        }

        /// Fill color when the false side is selected; nil keeps a neutral thumb.
        var falseFill: Color? {
            switch self {
            case .transaction: nil
            case .account: .green
            }
        }

        /// Fill color when the true side is selected; nil keeps a neutral thumb.
        var trueFill: Color? {
            switch self {
            case .transaction: .green
            case .account: .red
            }
        }
    }

    @Binding var selection: Bool
    let style: Style

    var body: some View {
        HStack(spacing: 0) {
            segment(label: style.falseLabel, fill: style.falseFill, isSelected: !selection) {
                selection = false
            }
            segment(label: style.trueLabel, fill: style.trueFill, isSelected: selection) {
                selection = true
            }
        }
        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 9))
        .animation(.easeInOut(duration: 0.2), value: selection)
    }

    /// One tappable half of the control.
    private func segment(label: String, fill: Color?, isSelected: Bool,
                         action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.callout.weight(.medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .foregroundStyle(foreground(fill: fill, isSelected: isSelected))
                .background(background(fill: fill, isSelected: isSelected))
                .contentShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func foreground(fill: Color?, isSelected: Bool) -> Color {
        guard isSelected else { return .secondary }
        return fill == nil ? .primary : .white
    }

    @ViewBuilder
    private func background(fill: Color?, isSelected: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 8)
                .fill(fill ?? Color(.secondarySystemGroupedBackground))
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        SegmentedToggle(selection: .constant(false), style: .transaction)
        SegmentedToggle(selection: .constant(true), style: .transaction)
        SegmentedToggle(selection: .constant(false), style: .account)
        SegmentedToggle(selection: .constant(true), style: .account)
    }
    .padding()
}
