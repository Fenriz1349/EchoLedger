//
//  AddInstitutionFormView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 26/03/2026.
//

import SwiftUI
import CustomTextFields
import CustomLabels

struct AddInstitutionFormView: View {

    @State var viewModel: AddInstitutionFormViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CustomTextField.immediate(
                placeholder: "Nom de l'établissement",
                text: $viewModel.name,
                type: .alphaNumber,
                validator: { $0.trimmingCharacters(in: .whitespaces).count >= 2 },
                errorMessage: "Le nom doit contenir au moins 2 caractères"
            )

            Picker("Type", selection: $viewModel.type) {
                ForEach(InstitutionType.allCases, id: \.self) { type in
                    Label(type.name, systemImage: type.icon)
                        .tag(type)
                }
            }
            .pickerStyle(.menu)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Button {
                Task { await viewModel.submit() }
            } label: {
                CustomButtonLabel(
                    message: "Ajouter l'établissement",
                    color: .accentColor,
                    isSelected: viewModel.isValid
                )
            }
            .disabled(!viewModel.isValid || viewModel.isLoading)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AddInstitutionFormView(viewModel: .preview())
        .environment(DIContainer.preview())
}
