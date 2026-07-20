//
//  SyncButton.swift
//  EchoLedger
//
//  Created by Julien Cotte on 17/04/2026.
//

import SwiftUI

struct SyncButton: View {
    let syncManager: SyncManager

    var body: some View {
        HStack {
            if let date = syncManager.lastSyncDate {
                TimelineView(.everyMinute) { _ in
                    Text("Sync : \(date.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button {
                Task { await syncManager.sync() }
            } label: {
                if syncManager.status == .syncing {
                    EchoLedgerLoader()
                } else {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .disabled(syncManager.status == .syncing)
        }
    }
}

#Preview {
    SyncButton(syncManager: PreviewHelpers.container.syncManager)
}
