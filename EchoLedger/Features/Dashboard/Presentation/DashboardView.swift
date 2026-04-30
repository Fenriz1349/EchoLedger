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
    @State private var showProfile = false

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
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showProfile = true
                    } label: {
                        Image(systemName: "person.circle")
                            .font(.system(size: 18))
                    }
                }
            }
            .sheet(isPresented: $showProfile) {
                UserProfileView(viewModel: coordinator.makeUserProfileViewModel())
            }
        }
    }
}

#Preview {
    DashboardView(coordinator: PreviewHelpers.appCoordinator)
        .environment(PreviewHelpers.container)
}
