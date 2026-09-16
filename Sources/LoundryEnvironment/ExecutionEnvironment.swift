import Foundation
import LoundryModels

public struct EnvironmentResult: Sendable, Hashable {
    public let exitCode: Int32
    public let output: String

    public init(exitCode: Int32, output: String = "") {
        self.exitCode = exitCode
        self.output = output
    }

    public var succeeded: Bool { exitCode == 0 }
}

public protocol ExecutionEnvironment: Sendable {
    var spec: EnvironmentSpec { get }
    func run(_ command: EnvironmentCommand) async throws -> EnvironmentResult
    func writeFile(path: String, contents: String) async throws
    func readFile(path: String) async throws -> String
    func exists(path: String) async -> Bool
}

public enum EnvironmentError: Error, Sendable, Equatable {
    case unsupportedPlatform
    case commandFailed(Int32)
    case fileNotFound(String)
    case invalidPath(String)
}

public actor InMemoryEnvironment: ExecutionEnvironment {
    public let spec: EnvironmentSpec
    private var files: [String: String]
    private var commandResults: [String: EnvironmentResult]

    public init(
        spec: EnvironmentSpec,
        files: [String: String] = [:],
        commandResults: [String: EnvironmentResult] = [:]
    ) {
        self.spec = spec
        self.files = files
        self.commandResults = commandResults
    }

    public func run(_ command: EnvironmentCommand) async throws -> EnvironmentResult {
        if let result = commandResults[command.displayCommand] {
            return result
        }
        return EnvironmentResult(exitCode: 0)
    }

    public func writeFile(path: String, contents: String) async throws {
        guard !path.isEmpty, path.first != "~" else {
            throw EnvironmentError.invalidPath(path)
        }
        files[path] = contents
    }

    public func readFile(path: String) async throws -> String {
        guard let contents = files[path] else {
            throw EnvironmentError.fileNotFound(path)
        }
        return contents
    }

    public func exists(path: String) async -> Bool {
        files[path] != nil
    }

    public func setCommandResult(_ result: EnvironmentResult, for command: EnvironmentCommand) {
        commandResults[command.displayCommand] = result
    }
}
