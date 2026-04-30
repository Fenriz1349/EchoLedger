//
//  DashboardView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI

/// Displays the main dashboard with global balance, recent transactions, and sync status.
struct DashboardView: View {

    let coordinator: AppCoordinator
    @Environment(DIContainer.self) private var container

    var body: some View {
        NavigationStack {
            VStack {
                SyncButton(syncManager: container.syncManager)
                    .padding(.horizontal)

                Text("Tableau de bord — solde global et transactions récentes")
                    .padding()

                Spacer()
            }
            .navigationTitle("Tableau de bord")
            .toolbar {
                if container.authSession.isAnonymous {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Démo")
                            .font(.caption.bold())
                            .foregroundColor(.orange)
                            .fixedSize()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.orange.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
}

#Preview {
    DashboardView(coordinator: PreviewHelpers.appCoordinator)
        .environment(PreviewHelpers.container)
}
