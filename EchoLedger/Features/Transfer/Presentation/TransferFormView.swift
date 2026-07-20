//
//  TransferFormView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 22/05/2026.
//

import SwiftUI
import CustomLabels
import CustomTextFields

/// Form to create an internal transfer between two active accounts.
struct TransferFormView: View {

    @State var viewModel: TransferFormViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                    Form {
                        Section("Comptes") {
                            VStack(spacing: 0) {
                                Picker("De", selection: $viewModel.sourceAccountId) {
                                    ForEach(viewModel.sourceOptions) { item in
                                        Text(item.displayLabel).tag(Optional(item.account.id))
                                    }
                                }
                                .padding(.vertical, 6)
                                Divider()
                                Picker("Vers", selection: $viewModel.destinationAccountId) {
                                    ForEach(viewModel.destinationOptions) { item in
                                        Text(item.displayLabel).tag(Optional(item.account.id))
                                    }
                                }
                                .padding(.vertical, 6)
                            }
                            .overlay {
                                GeometryReader { proxy in
                                    Button {
                                        viewModel.swapAccounts()
                                    } label: {
                                        Image(systemName: "arrow.up.arrow.down")
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(Color.echoAccentHard)
                                            .frame(width: 40, height: 40)
                                            .background(Color.echoAccentSoft,
                                                       in: RoundedRectangle(cornerRadius: .echoCorner))
                                    }
                                    .buttonStyle(.plain)
                                    .position(x: proxy.size.width / 4, y: proxy.size.height / 2)
                                }
                            }
                        }
                        .listRowBackground(Color.echoCard)

                        Section("Montant") {
                            HStack {
                                CustomTextField(
                                    placeholder: "0,00€",
                                    text: $viewModel.amountText,
                                    type: .decimal,
                                    colors: .echo,
                                    cornerRadius: .echoCorner,
                                    hasShadow: false
                                )
                                .onChange(of: viewModel.amountText) { viewModel.sanitizeAmount() }
                            }
                            DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
                        }
                        .listRowBackground(Color.echoCard)

                        Section("Description (optionnel)") {
                            CustomTextField(
                                placeholder: "Ex : virement livret",
                                text: $viewModel.label,
                                type: .alphaNumber,
                                colors: .echo,
                                cornerRadius: .echoCorner,
                                hasShadow: false
                            )
                        }
                        .listRowBackground(Color.echoCard)

                        Section {
                            Button {
                                Task { await viewModel.submit() }
                            } label: {
                                CustomButtonLabel(
                                    iconLeading: "arrow.left.arrow.right",
                                    message: viewModel.isEditing ? "Modifier le transfert" : "Transférer",
                                    color: .accentColor,
                                    isSelected: viewModel.isFormValid
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(!viewModel.isFormValid || viewModel.isLoading)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                            .padding(.horizontal)
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                }
            .navigationTitle(viewModel.isEditing ? "Modifier le transfert" : "Transfert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
            .onChange(of: viewModel.isSuccess) {
                if viewModel.isSuccess { dismiss() }
            }
            .task {
                await viewModel.loadAccounts()
            }
            .echoBackground()
        }
        .overlay {
            if viewModel.isLoading {
                EchoProgressView()
            }
        }
    }
}

#Preview {
    TransferFormView(viewModel: PreviewHelpers.transferFormViewModel)
}
