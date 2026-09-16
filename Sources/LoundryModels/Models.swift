import Foundation

public struct LoundryProject: Codable, Sendable, Hashable, Identifiable {
    public let id: UUID
    public var name: String
    public var idea: String
    public var targets: [BuildTarget]

    public init(
        id: UUID = UUID(),
        name: String = "untitled project",
        idea: String = "",
        targets: [BuildTarget] = [.ios]
    ) {
        self.id = id
        self.name = name
        self.idea = idea
        self.targets = targets
    }
}

public enum BuildTarget: String, Codable, Sendable, CaseIterable, Hashable {
    case ios
    case macos
    case windows
    case linux
}

public struct EnvironmentSpec: Codable, Sendable, Hashable {
    public var operatingSystem: OperatingSystem
    public var shell: Shell
    public var workingDirectory: String
    public var environmentVariables: [String: String]

    public init(
        operatingSystem: OperatingSystem,
        shell: Shell,
        workingDirectory: String = "/workspace",
        environmentVariables: [String: String] = [:]
    ) {
        self.operatingSystem = operatingSystem
        self.shell = shell
        self.workingDirectory = workingDirectory
        self.environmentVariables = environmentVariables
    }
}

public enum OperatingSystem: String, Codable, Sendable, CaseIterable, Hashable {
    case linux
    case windows
    case macos
}

public enum Shell: String, Codable, Sendable, CaseIterable, Hashable {
    case bash
    case zsh
    case powershell
}

public struct EnvironmentCommand: Codable, Sendable, Hashable {
    public let executable: String
    public let arguments: [String]

    public init(executable: String, arguments: [String] = []) {
        self.executable = executable
        self.arguments = arguments
    }

    public var displayCommand: String {
        ([executable] + arguments).map(Self.quote).joined(separator: " ")
    }

    private static func quote(_ value: String) -> String {
        guard value.contains(where: { $0.isWhitespace || $0 == '"' }) else { return value }
        return "\"\(value.replacingOccurrences(of: "\"", with: "\\\""))\""
    }
}
