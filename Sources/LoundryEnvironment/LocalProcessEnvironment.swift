import Foundation
import LoundryEnvironment
import LoundryModels

public struct LocalProcessEnvironment: ExecutionEnvironment {
    public let spec: EnvironmentSpec

    public init(spec: EnvironmentSpec) {
        self.spec = spec
    }

    public func run(_ command: EnvironmentCommand) async throws -> EnvironmentResult {
        #if os(Windows)
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "C:\\Windows\\System32\\cmd.exe")
        process.arguments = ["/C", command.displayCommand]
        #else
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-lc", command.displayCommand]
        #endif

        let output = Pipe()
        process.standardOutput = output
        process.standardError = output
        process.currentDirectoryURL = URL(fileURLWithPath: spec.workingDirectory)
        process.environment = ProcessInfo.processInfo.environment.merging(
            spec.environmentVariables,
            uniquingKeysWith: { _, new in new }
        )

        try process.run()
        process.waitUntilExit()
        let data = output.fileHandleForReading.readDataToEndOfFile()
        return EnvironmentResult(
            exitCode: process.terminationStatus,
            output: String(data: data, encoding: .utf8) ?? ""
        )
    }

    public func writeFile(path: String, contents: String) async throws {
        let url = URL(fileURLWithPath: path)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try contents.data(using: .utf8)?.write(to: url, options: .atomic)
    }

    public func readFile(path: String) async throws -> String {
        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            throw EnvironmentError.fileNotFound(path)
        }
    }

    public func exists(path: String) async -> Bool {
        FileManager.default.fileExists(atPath: path)
    }
}
