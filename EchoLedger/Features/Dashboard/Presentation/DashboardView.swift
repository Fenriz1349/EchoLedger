//
//  DashboardView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI

struct DashboardView: View {

    var body: some View {
        NavigationStack {
            Text("Tableau de bord — solde global et transactions récentes")
                .navigationTitle("Tableau de bord")
        }
    }
}

#Preview {
    DashboardView()
        .environment(DIContainer(
            userId: PreviewData.user.id,
            toasty: PreviewData.toasty,
            authStoring: PreviewData.authStoring,
            authSession: PreviewData.authSession,
            inMemory: true
        ))
}
