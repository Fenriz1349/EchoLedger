//
//  SafariDocumentView.swift
//  EchoLedger
//
//  Created by Julien Cotte on 05/06/2026.
//

import SwiftUI
import SafariServices

/// Presents a remote document (image or PDF) full screen using SFSafariViewController.

struct SafariDocumentView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
