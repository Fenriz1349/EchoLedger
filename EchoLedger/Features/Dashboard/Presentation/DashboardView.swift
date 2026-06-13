//
//  DashboardView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI

/// Displays the main dashboard: total balance, per-account breakdown, and expense/income charts.
struct DashboardView: View {

    let coordinator: AppCoordinator

    var body: some View {
        NavigationStack {
            Group {
                if coordinator.userProfileViewModel.isAnonymous {
                    AnonymousHeaderView(dayInDemo: coordinator.userProfileViewModel.daysRemainingInDemo)
                }
                List {
                    // MARK: Total balance
                    Section {
                        HStack {
                            Text("Solde total")
                                .font(.headline)
                            Spacer()
                            Text(coordinator.dashboardViewModel.totalBalance.toEuro)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(
                                    coordinator.dashboardViewModel.totalBalance >= 0
                                    ? Color.green : Color.red
                                )
                        }
                    }

                    // MARK: Per-account breakdown
                    if !coordinator.dashboardViewModel.accountBalances.isEmpty {
                        Section {
                            AccountBalanceChartView(
                                items: coordinator.dashboardViewModel.accountBalances
                            )
                        }
                    }

                    // MARK: Monthly income / expense
                    if !coordinator.dashboardViewModel.monthlyFlows.isEmpty {
                        Section {
                            MonthlyFlowChartView(
                                data: coordinator.dashboardViewModel.monthlyFlows
                            )
                        }
                    }

                    // MARK: Expense chart
                    if !coordinator.dashboardViewModel.expenseTotals.isEmpty {
                        Section {
                            ExpensePieChartView(data: coordinator.dashboardViewModel.expenseTotals)
                        }
                    }

                    // MARK: Income chart
                    if !coordinator.dashboardViewModel.incomeTotals.isEmpty {
                        Section {
                            IncomePieChartView(data: coordinator.dashboardViewModel.incomeTotals)
                        }
                    }
                }
                .refreshable {
                    await coordinator.dashboardViewModel.load()
                }
                .navigationTitle("Tableau de bord")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
            #if CLOUD_TARGET
                Button {
                    Task {
                        await coordinator.dashboardViewModel.load()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                #else
                SyncButton(syncManager: coordinator.syncManager)
                #endif
            }
            if coordinator.authSession.isAnonymous {
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
        .task {
            await coordinator.dashboardViewModel.load()
        }
        .overlay {
            if coordinator.dashboardViewModel.isLoading {
                EchoProgressView()
            }
        }
    }
}

#Preview {
    DashboardView(coordinator: PreviewHelpers.appCoordinator)
        .environment(PreviewHelpers.container)
}
