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
    private let planner: ProjectPlanner

    public init(planner: ProjectPlanner = ProjectPlanner()) {
        self.planner = planner
    }

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
                    state.setPhase(.failed)
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
        continuation.yield(.planning("checking targets and execution capabilities"))

        var instruction = "generate the project"
        var lastFailure: String?

        for attempt in 0...request.maxRepairAttempts {
            if attempt > 0 {
                state.setPhase(.repairing)
                state.incrementAttempt()
                instruction = "repair the project after this failure: \(lastFailure ?? \"unknown build failure\")"
                continuation.yield(.retrying(attempt: state.attempt, reason: lastFailure ?? "build failed"))
            }

            state.setPhase(.generating)
            continuation.yield(.modelStarted(provider: request.model.providerID, model: request.model.modelID))

            let generated = try await generate(
                request: request,
                instruction: instruction,
                continuation: continuation
            )

            let manifest = ProjectManifest(
                files: generated.files,
                buildCommands: generated.commands
            )

            _ = try planner.makePlan(
                for: request.project,
                manifest: manifest,
                in: request.environment
            )

            state.setPhase(.building)
            let buildResult = try await execute(
                generated.commands,
                environment: request.environment,
                continuation: continuation
            )

            if buildResult.succeeded {
                state.setPhase(.testing)
                continuation.yield(.planning("running verification passes"))
                continuation.yield(.testPassed("generated build commands"))
                state.setPhase(.completed)
                continuation.yield(.completed)
                return
            }

            lastFailure = buildResult.failure
        }

        throw EnvironmentError.commandFailed(1)
    }

    private func generate(
        request: BuildRequest,
        instruction: String,
        continuation: AsyncThrowingStream<ActivityEvent, Error>.Continuation
    ) async throws -> GeneratedOutput {
        var files: [ProjectFile] = []
        var commands: [EnvironmentCommand] = []

        for try await event in request.model.generate(
            for: ModelRequest(project: request.project, instruction: instruction)
        ) {
            switch event {
            case .text(let text):
                continuation.yield(.modelOutput(text))
            case .file(let path, let contents):
                try await request.environment.writeFile(path: path, contents: contents)
                files.append(ProjectFile(path: path, contents: contents))
                continuation.yield(.fileWritten(path: path))
            case .command(let command):
                commands.append(command)
            case .finished:
                break
            }
        }

        return GeneratedOutput(files: files, commands: commands)
    }

    private func execute(
        _ commands: [EnvironmentCommand],
        environment: any ExecutionEnvironment,
        continuation: AsyncThrowingStream<ActivityEvent, Error>.Continuation
    ) async throws -> CommandBatchResult {
        guard !commands.isEmpty else {
            return CommandBatchResult(succeeded: true, failure: nil)
        }

        for command in commands {
            continuation.yield(.commandStarted(command))
            let result = try await environment.run(command)
            if !result.output.isEmpty {
                continuation.yield(.commandOutput(result.output))
            }
            continuation.yield(.commandFinished(exitCode: result.exitCode))

            guard result.succeeded else {
                return CommandBatchResult(
                    succeeded: false,
                    failure: "\(command.displayCommand) exited with \(result.exitCode): \(result.output)"
                )
            }
        }

        return CommandBatchResult(succeeded: true, failure: nil)
    }
}

private struct GeneratedOutput: Sendable {
    let files: [ProjectFile]
    let commands: [EnvironmentCommand]
}

private struct CommandBatchResult: Sendable {
    let succeeded: Bool
    let failure: String?
}
