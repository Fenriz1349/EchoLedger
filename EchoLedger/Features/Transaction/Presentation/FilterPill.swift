//
//  FilterPill.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import SwiftUI

/// A capsule-shaped pill used in filter bars.
/// When active and a `systemImage` is provided, the icon replaces the text label — keeping the pill compact.
/// When inactive, always shows the text label.
struct FilterPill: View {

    let label: String
    let isActive: Bool
    var systemImage: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            if isActive, let icon = systemImage {
                Image(systemName: icon)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            } else {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(isActive ? .semibold : .regular)
                    .lineLimit(1)
            }
            Image(systemName: "chevron.down")
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(isActive ? Color.accentColor : Color.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(isActive ? Color.accentColor.opacity(0.12) : Color(.tertiarySystemFill))
        )
    }
}

#Preview {
    VStack(spacing: 12) {
        HStack(spacing: 8) {
            FilterPill(label: "Nature", isActive: false)
            FilterPill(label: "Dépenses", isActive: true, systemImage: "arrow.down")
            FilterPill(label: "Catégorie", isActive: false)
            FilterPill(label: "Courses", isActive: true, systemImage: "basket")
        }
        HStack(spacing: 8) {
            FilterPill(label: "Nature", isActive: false)
            FilterPill(label: "Revenus", isActive: true, systemImage: "arrow.up")
            FilterPill(label: "Compte", isActive: false)
            FilterPill(label: "Compte courant", isActive: true)
        }
    }
    .padding()
}
