import Foundation

public enum ActivityEvent: Sendable, Hashable {
    case receivedIdea(String)
    case planning(String)
    case modelStarted(provider: String, model: String)
    case modelOutput(String)
    case fileWritten(path: String)
    case commandStarted(EnvironmentCommand)
    case commandOutput(String)
    case commandFinished(exitCode: Int32)
    case testPassed(String)
    case testFailed(String)
    case retrying(attempt: Int, reason: String)
    case completed
    case failed(String)

    public var summary: String {
        switch self {
        case .receivedIdea: return "idea received"
        case .planning(let message): return message
        case .modelStarted(let provider, let model): return "using \(provider) / \(model)"
        case .modelOutput(let text): return text
        case .fileWritten(let path): return "wrote \(path)"
        case .commandStarted(let command): return "$ \(command.displayCommand)"
        case .commandOutput(let text): return text
        case .commandFinished(let exitCode): return "command exited with \(exitCode)"
        case .testPassed(let name): return "test passed: \(name)"
        case .testFailed(let name): return "test failed: \(name)"
        case .retrying(let attempt, let reason): return "retry \(attempt): \(reason)"
        case .completed: return "project completed"
        case .failed(let reason): return "project failed: \(reason)"
        }
    }
}

public enum BuildPhase: String, Sendable, Hashable {
    case idle
    case planning
    case generating
    case building
    case testing
    case repairing
    case completed
    case failed
}

public struct BuildState: Sendable, Hashable {
    public private(set) var phase: BuildPhase = .idle
    public private(set) var attempt: Int = 0

    public init() {}

    public mutating func setPhase(_ phase: BuildPhase) {
        self.phase = phase
    }

    public mutating func incrementAttempt() {
        attempt += 1
    }
}
