//
//  ContentView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 18/11/2025.
//

import SwiftUI

struct ContentView: View {

    @Environment(DIContainer.self) private var container
    @Bindable var coordinator: AppCoordinator
    @State private var selectedTab: AppTab = .dashboard

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(coordinator: coordinator)
                .tabItem { Label("", systemImage: "chart.pie") }
                .tag(AppTab.dashboard)

            TransactionListView(coordinator: coordinator)
                .tabItem { Label("", systemImage: "list.bullet") }
                .tag(AppTab.transactions)

            Color.clear
                .tag(AppTab.add)
                .disabled(true)

            AccountListView(coordinator: coordinator)
                .tabItem { Label("", systemImage: "building.columns") }
                .tag(AppTab.accounts)

            if container.authSession.isAnonymous {
                UserProfileAnonymousView(viewModel: coordinator.userProfileViewModel)
                    .tabItem { Label("", systemImage: "person.circle") }
                    .tag(AppTab.profile)
            } else {
                UserProfileView(viewModel: coordinator.userProfileViewModel)
                    .tabItem { Label("", systemImage: "person.circle") }
                    .tag(AppTab.profile)
            }
        }
        .overlay(alignment: .bottom) {
            ZStack {
                Button {
                    coordinator.transactionListViewModel.showAddTransaction = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .background(
                                    Circle().fill(Color.accentColor)
                                )
                        )
                        .shadow(radius: 6)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .sheet(
            isPresented: $coordinator.transactionListViewModel.showAddTransaction,
            onDismiss: { Task { await coordinator.loadData() } }
        ) {
            TransactionFormView(viewModel: coordinator.makeTransactionFormViewModel())
        }
        .onChange(of: selectedTab) { old, new in
            if new == .add {
                selectedTab = old
                coordinator.transactionListViewModel.showAddTransaction = true
            }
        }
        .overlay {
            SuccessCheckmarkView(isPresented: $coordinator.transactionListViewModel.showSuccessCheckmark)
        }
    }
}

private enum AppTab: Hashable {
    case dashboard, transactions, add, accounts, profile
}

#Preview {
    ContentView(coordinator: PreviewHelpers.appCoordinator)
        .environment(PreviewHelpers.container)
}
