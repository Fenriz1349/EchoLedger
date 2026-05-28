//
//  InstitutionFormView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 28/05/2026.
//

import SwiftUI

/// Sheet wrapping InstitutionFormContent for editing an existing institution.
/// Presented when tapping an institution name in AccountListView.
struct InstitutionFormView: View {

    @State var viewModel: InstitutionFormViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                InstitutionFormContent(viewModel: viewModel)
                    .padding()
            }
            .navigationTitle(viewModel.isArchived ? "Établissement archivé" : "Modifier l'établissement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .onChange(of: viewModel.isSuccess) {
                if viewModel.isSuccess { dismiss() }
            }
        }
    }
}

#Preview {
    InstitutionFormView(viewModel: PreviewHelpers.makeInstitutionFormViewModel())
        .environment(PreviewHelpers.container)
}
