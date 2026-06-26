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
                            Spacer()
                            AnimatedAmountView(value: coordinator.dashboardViewModel.graphsViewModel.totalBalance)
                        }
                        .font(.headline)
                    }
                    .listRowBackground(Color.echoCard)

                    // MARK: Monthly income / expense
                    if !coordinator.dashboardViewModel.graphsViewModel.monthlyFlows.isEmpty {
                        Section {
                            MonthlyFlowChartView(
                                data: coordinator.dashboardViewModel.graphsViewModel.monthlyFlows
                            )
                        }
                        .listRowBackground(Color.echoCard)
                    }

                    // MARK: Monthly pie carousel
                    if !coordinator.dashboardViewModel.graphsViewModel.monthlyPieData.isEmpty {
                        Section {
                            MonthlyPieCarouselView(
                                months: coordinator.dashboardViewModel.graphsViewModel.monthlyPieData,
                                currentIndex: coordinator.dashboardViewModel.graphsViewModel.selectedPieIndex,
                                onPrevious: { coordinator.dashboardViewModel.graphsViewModel.goToPreviousPie() },
                                onNext: { coordinator.dashboardViewModel.graphsViewModel.goToNextPie() },
                                onSwipe: { coordinator.dashboardViewModel.graphsViewModel.handlePieSwipe($0) }
                            )
                        }
                        .listRowBackground(Color.echoCard)
                    }

                    // MARK: Expense chart
                    if !coordinator.dashboardViewModel.graphsViewModel.expenseTotals.isEmpty {
                        Section {
                            ExpensePieChartView(
                                data: coordinator.dashboardViewModel.graphsViewModel.expenseTotals
                            )
                        }
                        .listRowBackground(Color.echoCard)
                    }

                    // MARK: Income chart
                    if !coordinator.dashboardViewModel.graphsViewModel.incomeTotals.isEmpty {
                        Section {
                            IncomePieChartView(
                                data: coordinator.dashboardViewModel.graphsViewModel.incomeTotals
                            )
                        }
                        .listRowBackground(Color.echoCard)
                    }
                }
                .refreshable {
                    await coordinator.dashboardViewModel.refresh()
                }
                .echoBackground()
                .navigationTitle("Tableau de bord")
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
            #if CLOUD_TARGET
                Button {
                    Task { await coordinator.dashboardViewModel.refresh() }
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
