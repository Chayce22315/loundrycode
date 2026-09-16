import XCTest
@testable import LoundryModels

final class ToolchainTests: XCTestCase {
    func testManifestCanContainMultipleLanguages() throws {
        let manifest = ProjectManifest(
            toolchains: [
                Toolchain(id: "swift", displayName: "swift", language: .swift),
                Toolchain(id: "rust", displayName: "rust", language: .rust),
                Toolchain(id: "typescript", displayName: "typescript", language: .typescript)
            ],
            files: [
                ProjectFile(path: "Sources/App.swift", language: .swift),
                ProjectFile(path: "tools/build.ts", language: .typescript)
            ]
        )

        let data = try JSONEncoder().encode(manifest)
        let decoded = try JSONDecoder().decode(ProjectManifest.self, from: data)

        XCTAssertEqual(decoded.toolchains.count, 3)
        XCTAssertEqual(decoded.files.first?.language, .swift)
        XCTAssertEqual(decoded.files.last?.language, .typescript)
    }
}
