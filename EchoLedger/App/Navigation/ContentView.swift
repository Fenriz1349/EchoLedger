//
//  ContentView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 18/11/2025.
//

import SwiftUI

struct ContentView: View {

    @Environment(DIContainer.self) private var container
    @State private var showAddTransaction = false

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Tableau de bord", systemImage: "chart.pie")
                }

            TransactionListView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }

            AccountListView(viewModel: container.makeAccountListViewModel())
                .tabItem {
                    Label("Comptes", systemImage: "building.columns")
                }
        }
        .overlay(alignment: .bottom) {
            Button {
                showAddTransaction = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 56, height: 56)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
            }
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
    }
}

#Preview {
    ContentView()
        .environment(DIContainer(inMemory: true))
}
