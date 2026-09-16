import XCTest
@testable import LoundryCore
@testable import LoundryEnvironment
import LoundryModels

final class LoundryCoreTests: XCTestCase {
    func testUsageLedgerDefaultsToFreeLimit() async {
        let ledger = UsageLedger()
        let snapshot = await ledger.snapshot()
        XCTAssertEqual(snapshot.slotLimit, UsageLedger.freeSlotLimit)
        XCTAssertEqual(snapshot.remainingUnorthodoxSlots, 10)
    }

    func testUsageLedgerRefreshesAfterWindow() async {
        let ledger = UsageLedger()
        let start = Date(timeIntervalSince1970: 1_000)
        XCTAssertTrue(await ledger.consumeUnorthodoxSlot(now: start))
        let before = await ledger.snapshot(now: start.addingTimeInterval(UsageLedger.refreshInterval - 1))
        XCTAssertEqual(before.usedUnorthodoxSlots, 1)

        let after = await ledger.snapshot(now: start.addingTimeInterval(UsageLedger.refreshInterval + 1))
        XCTAssertEqual(after.usedUnorthodoxSlots, 0)
    }

    func testOrchestratorStreamsVisibleActivity() async throws {
        let environment = InMemoryEnvironment(
            spec: EnvironmentSpec(operatingSystem: .linux, shell: .bash)
        )
        let model = StubModelProvider()
        let project = LoundryProject(name: "hello", idea: "make a tiny app")
        let orchestrator = LoundryOrchestrator()

        var summaries: [String] = []
        for try await event in await orchestrator.build(
            BuildRequest(project: project, environment: environment, model: model)
        ) {
            summaries.append(event.summary)
        }

        XCTAssertTrue(summaries.contains("idea received"))
        XCTAssertTrue(summaries.contains("wrote /workspace/hello.txt"))
        XCTAssertTrue(summaries.contains("project completed"))
        XCTAssertEqual(await orchestrator.currentState().phase, .completed)
    }
}

private struct StubModelProvider: ModelProvider {
    let providerID = "test"
    let modelID = "stub"

    func generate(for request: ModelRequest) -> AsyncThrowingStream<ModelEvent, Error> {
        AsyncThrowingStream { continuation in
            continuation.yield(.text("plan ready"))
            continuation.yield(.file(path: "/workspace/hello.txt", contents: "hello"))
            continuation.yield(.command(EnvironmentCommand(executable: "echo", arguments: ["hello"])))
            continuation.yield(.finished)
            continuation.finish()
        }
    }
}
