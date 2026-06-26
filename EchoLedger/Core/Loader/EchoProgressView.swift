//
//  EchoProgressView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 05/06/2026.
//

import SwiftUI

struct EchoProgressView: View {

    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            EchoLedgerLoader()
                .frame(width: 80, height: 80)
                .padding(20)
                .background(Color.echoBackground, in: RoundedRectangle(cornerRadius: 28))
        }
    }
}

#Preview {
    EchoProgressView()
}
