import XCTest
@testable import LoundryCore
@testable import LoundryEnvironment
import LoundryModels

final class ProjectPlannerTests: XCTestCase {
    func testPlannerAcceptsMultipleLanguagesOnCompatibleEnvironment() throws {
        let project = LoundryProject(
            name: "polyglot",
            idea: "make a tool",
            targets: [.linux]
        )
        let manifest = ProjectManifest(
            toolchains: [
                Toolchain(id: "rust", displayName: "rust", language: .rust),
                Toolchain(id: "python", displayName: "python", language: .python)
            ]
        )
        let environment = InMemoryEnvironment(
            spec: EnvironmentSpec(operatingSystem: .linux, shell: .bash)
        )

        let plan = try ProjectPlanner().makePlan(
            for: project,
            manifest: manifest,
            in: environment
        )

        XCTAssertEqual(plan.project.name, "polyglot")
        XCTAssertEqual(plan.manifest.toolchains.count, 2)
    }

    func testPlannerRejectsIOSOnLinux() async {
        let project = LoundryProject(
            name: "phone app",
            idea: "make an ios app",
            targets: [.ios]
        )
        let environment = InMemoryEnvironment(
            spec: EnvironmentSpec(operatingSystem: .linux, shell: .bash)
        )

        XCTAssertThrowsError(
            try ProjectPlanner().makePlan(
                for: project,
                manifest: ProjectManifest(),
                in: environment
            )
        ) { error in
            XCTAssertEqual(
                error as? PlannerError,
                .incompatibleTarget(target: .ios, operatingSystem: .linux)
            )
        }
    }
}
