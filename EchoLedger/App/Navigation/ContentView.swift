//
//  ContentView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 18/11/2025.
//

import SwiftUI

struct ContentView: View {

    @Environment(DIContainer.self) private var container
    let coordinator: AppCoordinator
    @State private var selectedTab: AppTab = .dashboard
    @State private var userProfileViewModel: UserProfileViewModel

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        self._userProfileViewModel = State(initialValue: coordinator.makeUserProfileViewModel())
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

            UserProfileView(viewModel: userProfileViewModel)
                .tabItem { Label("", systemImage: "person.circle") }
                .tag(AppTab.profile)
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
            isPresented: Binding(
                get: { coordinator.transactionListViewModel.showAddTransaction },
                set: { coordinator.transactionListViewModel.showAddTransaction = $0 }
            )
        ) {
            TransactionFormView(viewModel: coordinator.makeTransactionFormViewModel())
        }
        .onChange(of: selectedTab) { old, new in
            if new == .add {
                selectedTab = old
                coordinator.transactionListViewModel.showAddTransaction = true
            }
        }
        .onChange(of: coordinator.transactionListViewModel.showAddTransaction) {
            if !coordinator.transactionListViewModel.showAddTransaction {
                Task { await coordinator.transactionListViewModel.load() }
            }
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
