import Foundation
import LoundryModels

public struct BuildDiagnostic: Sendable, Hashable, Identifiable {
    public let id: UUID
    public let message: String
    public let command: EnvironmentCommand?
    public let exitCode: Int32?

    public init(
        id: UUID = UUID(),
        message: String,
        command: EnvironmentCommand? = nil,
        exitCode: Int32? = nil
    ) {
        self.id = id
        self.message = message
        self.command = command
        self.exitCode = exitCode
    }
}

public struct BuildAttempt: Sendable, Hashable, Identifiable {
    public let id: UUID
    public let number: Int
    public let instruction: String
    public let diagnostic: BuildDiagnostic?

    public init(
        id: UUID = UUID(),
        number: Int,
        instruction: String,
        diagnostic: BuildDiagnostic? = nil
    ) {
        self.id = id
        self.number = number
        self.instruction = instruction
        self.diagnostic = diagnostic
    }
}

public struct BuildOutcome: Sendable, Hashable {
    public let succeeded: Bool
    public let attempts: [BuildAttempt]
    public let diagnostics: [BuildDiagnostic]

    public init(
        succeeded: Bool,
        attempts: [BuildAttempt] = [],
        diagnostics: [BuildDiagnostic] = []
    ) {
        self.succeeded = succeeded
        self.attempts = attempts
        self.diagnostics = diagnostics
    }
}
