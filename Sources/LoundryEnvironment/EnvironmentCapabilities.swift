import Foundation
import LoundryModels

public struct EnvironmentCapabilities: Codable, Sendable, Hashable {
    public var operatingSystem: OperatingSystem
    public var shells: Set<Shell>
    public var languages: Set<ProjectLanguage>
    public var canExecuteProcesses: Bool
    public var canPersistFiles: Bool
    public var networkAccess: NetworkAccess

    public init(
        operatingSystem: OperatingSystem,
        shells: Set<Shell>,
        languages: Set<ProjectLanguage> = [],
        canExecuteProcesses: Bool = true,
        canPersistFiles: Bool = true,
        networkAccess: NetworkAccess = .restricted
    ) {
        self.operatingSystem = operatingSystem
        self.shells = shells
        self.languages = languages
        self.canExecuteProcesses = canExecuteProcesses
        self.canPersistFiles = canPersistFiles
        self.networkAccess = networkAccess
    }
}

public enum NetworkAccess: String, Codable, Sendable, CaseIterable, Hashable {
    case none
    case restricted
    case full
}

public protocol DescribedExecutionEnvironment: ExecutionEnvironment {
    var capabilities: EnvironmentCapabilities { get }
}
