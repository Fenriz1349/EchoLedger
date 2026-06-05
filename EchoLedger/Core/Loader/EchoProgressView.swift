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
            EchoLedgerLoader().frame(width: 80, height: 80)
        }
    }
}

#Preview {
    EchoProgressView()
}
