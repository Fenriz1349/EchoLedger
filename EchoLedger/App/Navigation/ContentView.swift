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

    var body: some View {
        Group {
            TabView {
                DashboardView(coordinator: coordinator)
                    .tabItem { Label("Tableau de bord", systemImage: "chart.pie") }

                TransactionListView(coordinator: coordinator)
                    .tabItem { Label("Transactions", systemImage: "list.bullet") }

                AccountListView(coordinator: coordinator)
                    .tabItem { Label("Comptes", systemImage: "building.columns") }
            }
            .overlay(alignment: .bottom) {
                Button {
                    coordinator.transactionListViewModel.showAddTransaction = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                }
                .padding(.bottom, 24)
            }

            .sheet(
                isPresented: Binding(
                    get: { coordinator.transactionListViewModel.showAddTransaction },
                    set: { coordinator.transactionListViewModel.showAddTransaction = $0 }
                )
            ) {
                TransactionFormView(
                    viewModel: coordinator.makeTransactionFormViewModel()
                )
            }
            .onChange(of: coordinator.transactionListViewModel.showAddTransaction) {
                if !coordinator.transactionListViewModel.showAddTransaction {
                    Task {
                        await coordinator.transactionListViewModel.load()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView(coordinator: PreviewHelpers.appCoordinator)
        .environment(PreviewHelpers.container)
}
