//
//  AccountFormView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI
import CustomTextFields
import CustomLabels

/// Modal form for creating or editing an account, including inline institution creation.
struct AccountFormView: View {

    @State var viewModel: AccountFormViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                AccountFormContent(viewModel: viewModel)
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle(viewModel.existingAccount == nil ? "Nouveau compte" : "Modifier le compte")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Fermer") { UIView.dismissKeyboard() }
                    Spacer()
                    Button(viewModel.existingAccount == nil ? "Ajouter" : "Modifier") {
                        UIView.dismissKeyboard()
                        Task { await viewModel.submit() }
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
            }
            .onChange(of: viewModel.isSuccess) {
                if viewModel.isSuccess { dismiss() }
            }
        }
    }
}

#Preview {
    AccountFormView(viewModel: PreviewHelpers.makeAccountFormViewModel())
        .environment(PreviewHelpers.container)
}
