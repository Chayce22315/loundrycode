import XCTest
@testable import LoundryCore
@testable import LoundryEnvironment
import LoundryModels

final class V02Tests: XCTestCase {
    func testPlannerRejectsProjectWithoutTargets() throws {
        let environment = InMemoryEnvironment(
            spec: EnvironmentSpec(operatingSystem: .linux, shell: .bash)
        )
        let project = LoundryProject(name: "empty", idea: "test", targets: [])

        XCTAssertThrowsError(
            try ProjectPlanner().makePlan(
                for: project,
                manifest: ProjectManifest(),
                in: environment
            )
        ) { error in
            XCTAssertEqual(error as? PlannerError, .noBuildTargets)
        }
    }

    func testActivityEventCarriesEnvironmentCommand() {
        let command = EnvironmentCommand(executable: "swift", arguments: ["build"])
        let event = ActivityEvent.commandStarted(command)

        XCTAssertEqual(event.summary, "$ swift build")
    }

    func testOrchestratorRetriesAfterBuildFailure() async throws {
        let command = EnvironmentCommand(executable: "build")
        let environment = InMemoryEnvironment(
            spec: EnvironmentSpec(operatingSystem: .linux, shell: .bash),
            commandResults: [
                command.displayCommand: EnvironmentResult(exitCode: 1, output: "compiler failed")
            ]
        )
        let model = RetryAwareModelProvider(command: command)
        let project = LoundryProject(
            name: "retry-test",
            idea: "make a project that can recover",
            targets: [.linux]
        )

        let orchestrator = LoundryOrchestrator()
        var events: [ActivityEvent] = []

        do {
            for try await event in await orchestrator.build(
                BuildRequest(project: project, environment: environment, model: model, maxRepairAttempts: 1)
            ) {
                events.append(event)
            }
            XCTFail("expected the build to fail after the retry budget")
        } catch {
            XCTAssertTrue(events.contains { event in
                if case .retrying(let attempt, _) = event { return attempt == 1 }
                return false
            })

            let state = await orchestrator.currentState()
            XCTAssertEqual(state.phase, .failed)
        }
    }
}

private struct RetryAwareModelProvider: ModelProvider {
    let command: EnvironmentCommand
    let providerID = "test"
    let modelID = "retry"

    func generate(for request: ModelRequest) -> AsyncThrowingStream<ModelEvent, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(.text(request.instruction))
            continuation.yield(.command(command))
            continuation.yield(.finished)
            continuation.finish()
        }
    }
}
