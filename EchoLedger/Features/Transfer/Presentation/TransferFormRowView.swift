//
//  TransferFormRowView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 24/07/2026.
//

import SwiftUI

/// A labeled account picker row ("De"/"Vers") for the transfer form, shown as a compact menu.
struct TransferFormRowView: View {

    let source: String
    let options: [AccountDisplayItem]
    @Binding var selection: UUID?

    /// The currently selected account's display label, or empty if none is selected yet.
    private var selectionLabel: String {
        options.first { $0.account.id == selection }?.displayLabel ?? ""
    }

    var body: some View {
        HStack {
            Text(source)
                .fixedSize()
            Spacer(minLength: 8)
            Menu {
                ForEach(options) { item in
                    Button(item.displayLabel) {
                        selection = item.account.id
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selectionLabel)
                        .lineLimit(1)
                        .layoutPriority(-1)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                }
                .foregroundStyle(Color.accentColor)
            }
        }
    }
}

#Preview {
    Form {
        TransferFormRowView(
            source: "De",
            options: PreviewHelpers.transferFormViewModel.sourceOptions,
            selection: .constant(PreviewData.accountCourant.id)
        )
    }
}
