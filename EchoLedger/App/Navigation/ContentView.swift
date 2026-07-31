//
//  ContentView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 18/11/2025.
//

import SwiftUI

/// The main tab-based screen shown once a user session is active.
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
                .tabItem { Label("", systemImage: "chart.pie").accessibilityIdentifier("tab.dashboard") }
                .tag(AppTab.dashboard)

            TransactionListView(coordinator: coordinator)
                .tabItem { Label("", systemImage: "list.bullet").accessibilityIdentifier("tab.transactions") }
                .tag(AppTab.transactions)

            Color.clear
                .tag(AppTab.add)
                .disabled(true)

            AccountListView(coordinator: coordinator)
                .tabItem { Label("", systemImage: "building.columns").accessibilityIdentifier("tab.accounts") }
                .tag(AppTab.accounts)

            if container.authSession.isAnonymous {
                UserProfileAnonymousView(viewModel: coordinator.userProfileViewModel)
                    .tabItem { Label("", systemImage: "person.circle").accessibilityIdentifier("tab.profile") }
                    .tag(AppTab.profile)
            } else {
                UserProfileView(viewModel: coordinator.userProfileViewModel)
                    .tabItem { Label("", systemImage: "person.circle").accessibilityIdentifier("tab.profile") }
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
                .accessibilityIdentifier("button.addTransaction")
            }
        }
        .ignoresSafeArea(.keyboard)
        .sheet(
            isPresented: Binding(
                get: { coordinator.transactionListViewModel.showAddTransaction },
                set: { coordinator.transactionListViewModel.showAddTransaction = $0 }
            ),
            onDismiss: { Task { await coordinator.loadData() } },
            content: {
                TransactionFormView(viewModel: coordinator.makeTransactionFormViewModel())
            }
        )
        .onChange(of: selectedTab) { old, new in
            if new == .add {
                selectedTab = old
                coordinator.transactionListViewModel.showAddTransaction = true
            }
        }
        .overlay {
            SuccessCheckmarkView(
                isPresented: Binding(
                    get: { coordinator.transactionListViewModel.showSuccessCheckmark },
                    set: { coordinator.transactionListViewModel.showSuccessCheckmark = $0 }
                )
            )
        }
    }
}

/// The tabs of the main TabView, including the disabled placeholder tab used for the floating add button.
private enum AppTab: Hashable {
    case dashboard, transactions, add, accounts, profile
}

#Preview {
    ContentView(coordinator: PreviewHelpers.appCoordinator)
        .environment(PreviewHelpers.container)
}
