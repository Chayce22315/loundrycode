import XCTest
@testable import LoundryEnvironment
import LoundryModels

final class LoundryEnvironmentTests: XCTestCase {
    func testInMemoryEnvironmentStoresFiles() async throws {
        let environment = InMemoryEnvironment(
            spec: EnvironmentSpec(operatingSystem: .linux, shell: .bash)
        )
        try await environment.writeFile(path: "/workspace/test.txt", contents: "hello")

        let exists = await environment.exists(path: "/workspace/test.txt")
        let contents = try await environment.readFile(path: "/workspace/test.txt")

        XCTAssertTrue(exists)
        XCTAssertEqual(contents, "hello")
    }

    func testInMemoryEnvironmentCanStubCommandResults() async throws {
        let environment = InMemoryEnvironment(
            spec: EnvironmentSpec(operatingSystem: .linux, shell: .bash)
        )
        let command = EnvironmentCommand(executable: "swift", arguments: ["--version"])
        await environment.setCommandResult(
            EnvironmentResult(exitCode: 0, output: "swift stub"),
            for: command
        )

        let result = try await environment.run(command)
        XCTAssertTrue(result.succeeded)
        XCTAssertEqual(result.output, "swift stub")
    }
}
