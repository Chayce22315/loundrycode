import Foundation

/// A language/toolchain descriptor. loundrycode does not require one implementation language.
public struct Toolchain: Codable, Sendable, Hashable, Identifiable {
    public let id: String
    public let displayName: String
    public let language: ProjectLanguage
    public let executableHints: [String]

    public init(
        id: String,
        displayName: String,
        language: ProjectLanguage,
        executableHints: [String] = []
    ) {
        self.id = id
        self.displayName = displayName
        self.language = language
        self.executableHints = executableHints
    }
}

public enum ProjectLanguage: String, Codable, Sendable, CaseIterable, Hashable {
    case swift
    case objectiveC = "objective-c"
    case rust
    case go
    case cpp
    case c
    case csharp
    case java
    case kotlin
    case python
    case javascript
    case typescript
    case ruby
    case php
    case zig
    case dart
    case lua
    case shell
    case other
}

public struct ProjectFile: Codable, Sendable, Hashable, Identifiable {
    public let path: String
    public var contents: String
    public var language: ProjectLanguage?

    public var id: String { path }

    public init(path: String, contents: String = "", language: ProjectLanguage? = nil) {
        self.path = path
        self.contents = contents
        self.language = language
    }
}

public struct ProjectManifest: Codable, Sendable, Hashable {
    public var toolchains: [Toolchain]
    public var files: [ProjectFile]
    public var buildCommands: [EnvironmentCommand]
    public var testCommands: [EnvironmentCommand]

    public init(
        toolchains: [Toolchain] = [],
        files: [ProjectFile] = [],
        buildCommands: [EnvironmentCommand] = [],
        testCommands: [EnvironmentCommand] = []
    ) {
        self.toolchains = toolchains
        self.files = files
        self.buildCommands = buildCommands
        self.testCommands = testCommands
    }
}
