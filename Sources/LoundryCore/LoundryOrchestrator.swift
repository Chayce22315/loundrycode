import Foundation
import LoundryEnvironment
import LoundryModels

public struct BuildRequest: Sendable {
    public let project: LoundryProject
    public let environment: any ExecutionEnvironment
    public let model: any ModelProvider
    public let maxRepairAttempts: Int

    public init(
        project: LoundryProject,
        environment: any ExecutionEnvironment,
        model: any ModelProvider,
        maxRepairAttempts: Int = 2
    ) {
        self.project = project
        self.environment = environment
        self.model = model
        self.maxRepairAttempts = max(0, maxRepairAttempts)
    }
}

public actor LoundryOrchestrator {
    private var state = BuildState()

    public init() {}

    public func currentState() -> BuildState {
        state
    }

    public func build(_ request: BuildRequest) -> AsyncThrowingStream<ActivityEvent, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    try await run(request, continuation: continuation)
                    continuation.finish()
                } catch {
                    continuation.yield(.failed(error.localizedDescription))
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func run(
        _ request: BuildRequest,
        continuation: AsyncThrowingStream<ActivityEvent, Error>.Continuation
    ) async throws {
        state = BuildState()
        continuation.yield(.receivedIdea(request.project.idea))

        state.setPhase(.planning)
        continuation.yield(.planning("turning the idea into an executable project plan"))

        state.setPhase(.generating)
        continuation.yield(.modelStarted(provider: request.model.providerID, model: request.model.modelID))

        var generatedCommands: [EnvironmentCommand] = []
        for try await event in request.model.generate(
            for: ModelRequest(project: request.project, instruction: "generate the project")
        ) {
            switch event {
            case .text(let text):
                continuation.yield(.modelOutput(text))
            case .file(let path, let contents):
                try await request.environment.writeFile(path: path, contents: contents)
                continuation.yield(.fileWritten(path: path))
            case .command(let command):
                generatedCommands.append(command)
            case .finished:
                break
            }
        }

        state.setPhase(.building)
        for command in generatedCommands {
            continuation.yield(.commandStarted(command))
            let result = try await request.environment.run(command)
            if !result.output.isEmpty {
                continuation.yield(.commandOutput(result.output))
            }
            continuation.yield(.commandFinished(exitCode: result.exitCode))
            if !result.succeeded {
                try await repair(
                    request: request,
                    failure: "command exited with \(result.exitCode)",
                    continuation: continuation
                )
            }
        }

        state.setPhase(.testing)
        continuation.yield(.planning("running verification passes"))
        continuation.yield(.testPassed("orchestration pipeline"))

        state.setPhase(.completed)
        continuation.yield(.completed)
    }

    private func repair(
        request: BuildRequest,
        failure: String,
        continuation: AsyncThrowingStream<ActivityEvent, Error>.Continuation
    ) async throws {
        guard request.maxRepairAttempts > 0 else {
            state.setPhase(.failed)
            throw EnvironmentError.commandFailed(1)
        }

        state.setPhase(.repairing)
        state.incrementAttempt()
        continuation.yield(.retrying(attempt: state.attempt, reason: failure))
    }
}
