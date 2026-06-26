//
//  OfflineView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 18/06/2026.
//

import SwiftUI
import CustomLabels

/// Full-screen state shown at launch when the user has a valid session but the backend can't be
/// reached. Mirrors `LoadingView`'s layout (fixed logo in the same spot) so the transition stays
/// smooth, with a message and a retry button below. Auto-retries when connectivity returns.
struct OfflineView: View {

    @Environment(NetworkMonitor.self) private var networkMonitor: NetworkMonitor?
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            AppHeaderView()

            VStack(spacing: 24) {
                Text("Pas de connexion internet.\nReconnecte-toi pour accéder à tes données.")
                    .font(.subheadline)
                    .foregroundStyle(.accent)
                    .multilineTextAlignment(.center)

                Button {
                    onRetry()
                } label: {
                    CustomButtonLabel(message: "Réessayer", color: .accentColor, isSelected: false)
                }
            }
            .padding(.horizontal, 32)
        }
        .echoBackground()
        .onChange(of: networkMonitor?.isConnected ?? false) { _, connected in
            if connected { onRetry() }
        }
    }
}

#Preview {
    OfflineView(onRetry: {})
}
