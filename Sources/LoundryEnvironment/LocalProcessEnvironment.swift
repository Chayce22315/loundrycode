import Foundation
import LoundryModels

public struct LocalProcessEnvironment: ExecutionEnvironment, DescribedExecutionEnvironment {
    public let spec: EnvironmentSpec
    public let capabilities: EnvironmentCapabilities

    public init(spec: EnvironmentSpec, capabilities: EnvironmentCapabilities? = nil) {
        self.spec = spec
        self.capabilities = capabilities ?? Self.defaultCapabilities(for: spec.operatingSystem, shell: spec.shell)
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
        guard let data = contents.data(using: .utf8) else {
            throw EnvironmentError.invalidPath(path)
        }
        try data.write(to: url, options: .atomic)
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

    private static func defaultCapabilities(
        for operatingSystem: OperatingSystem,
        shell: Shell
    ) -> EnvironmentCapabilities {
        let languages: Set<ProjectLanguage> = [
            .swift, .objectiveC, .rust, .go, .cpp, .c, .csharp,
            .java, .kotlin, .python, .javascript, .typescript,
            .ruby, .php, .zig, .dart, .lua, .shell
        ]

        return EnvironmentCapabilities(
            operatingSystem: operatingSystem,
            shells: [shell],
            languages: languages,
            canExecuteProcesses: true,
            canPersistFiles: true,
            networkAccess: .restricted
        )
    }
}
