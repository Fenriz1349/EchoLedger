//
//  SnapshotTestCase.swift
//  EchoLedgerTests
//
//  Created by Julien Cotte on 17/07/2026.
//

import XCTest
import SwiftUI

/// Fixed layout/trait configuration a view is rendered under for a snapshot.
struct SnapshotConfiguration {

    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection

    /// - Parameters:
    ///   - style: Light or dark appearance.
    ///   - contentSize: Dynamic Type category to render under.
    static func iPhone(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
        SnapshotConfiguration(
            size: CGSize(width: 390, height: 844),
            safeAreaInsets: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
            layoutMargins: UIEdgeInsets(top: 55, left: 8, bottom: 42, right: 8),
            traitCollection: UITraitCollection(mutations: { traits in
                traits.forceTouchCapability = .unavailable
                traits.layoutDirection = .leftToRight
                traits.preferredContentSizeCategory = contentSize
                traits.userInterfaceIdiom = .phone
                traits.horizontalSizeClass = .compact
                traits.verticalSizeClass = .regular
                traits.displayScale = 3
                traits.accessibilityContrast = .normal
                traits.displayGamut = .P3
                traits.userInterfaceStyle = style
            })
        )
    }
}

/// Off-screen window used to force a view controller through a fixed layout for rendering.
private final class SnapshotWindow: UIWindow {

    private var configuration: SnapshotConfiguration = .iPhone(style: .light)

    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        let dummyScene = (UIWindowScene.self as NSObject.Type).init() as! UIWindowScene
        self.init(windowScene: dummyScene)
        self.frame = CGRect(origin: .zero, size: configuration.size)
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }

    override var safeAreaInsets: UIEdgeInsets {
        configuration.safeAreaInsets
    }

    override var traitCollection: UITraitCollection {
        configuration.traitCollection
    }

    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return renderer.image { action in
            layer.render(in: action.cgContext)
        }
    }
}

extension View {

    func asViewController() -> UIViewController {
        UIHostingController(rootView: self)
    }
}

extension UIViewController {

    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

extension XCTestCase {

    /// Compares `snapshot` against the PNG stored under `name`, failing on any mismatch.
    /// - Parameter name: Identifies the reference file; call `record` once first to create it.
    func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            XCTFail(
                "Failed to load stored snapshot at URL: \(snapshotURL). Use `record` to store a snapshot first.",
                file: file, line: line
            )
            return
        }

        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(snapshotURL.lastPathComponent)
            try? snapshotData?.write(to: temporarySnapshotURL)
            XCTFail(
                "New snapshot does not match stored snapshot. New: \(temporarySnapshotURL), stored: \(snapshotURL)",
                file: file, line: line
            )
        }
    }

    /// Writes `snapshot` as the new reference PNG for `name`. Always fails, as a reminder to
    /// switch back to `assert` once the reference has been visually checked.
    func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

        do {
            try FileManager.default.createDirectory(
                at: snapshotURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try snapshotData?.write(to: snapshotURL)
            XCTFail("Record succeeded - switch back to `assert` to compare from now on.", file: file, line: line)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }

    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("Snapshots")
            .appendingPathComponent("\(name).png")
    }

    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        return data
    }
}
