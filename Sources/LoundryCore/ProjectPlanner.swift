import Foundation
import LoundryEnvironment
import LoundryModels

public struct ProjectPlan: Sendable, Hashable {
    public let project: LoundryProject
    public let manifest: ProjectManifest
    public let environment: EnvironmentSpec

    public init(
        project: LoundryProject,
        manifest: ProjectManifest,
        environment: EnvironmentSpec
    ) {
        self.project = project
        self.manifest = manifest
        self.environment = environment
    }
}

public struct ProjectPlanner: Sendable {
    public init() {}

    public func makePlan(
        for project: LoundryProject,
        manifest: ProjectManifest,
        in environment: some ExecutionEnvironment
    ) throws -> ProjectPlan {
        guard !project.idea.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PlannerError.emptyIdea
        }

        guard !project.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PlannerError.emptyProjectName
        }

        guard !project.targets.isEmpty else {
            throw PlannerError.noBuildTargets
        }

        for target in project.targets {
            guard isTargetCompatible(target, with: environment.spec.operatingSystem) else {
                throw PlannerError.incompatibleTarget(
                    target: target,
                    operatingSystem: environment.spec.operatingSystem
                )
            }
        }

        if let described = environment as? any DescribedExecutionEnvironment {
            guard described.capabilities.canPersistFiles else {
                throw PlannerError.filesystemUnavailable
            }

            if !manifest.buildCommands.isEmpty && !described.capabilities.canExecuteProcesses {
                throw PlannerError.processExecutionUnavailable
            }
        }

        return ProjectPlan(
            project: project,
            manifest: manifest,
            environment: environment.spec
        )
    }

    private func isTargetCompatible(_ target: BuildTarget, with operatingSystem: OperatingSystem) -> Bool {
        switch target {
        case .ios, .macos:
            return operatingSystem == .macos
        case .windows:
            return operatingSystem == .windows
        case .linux:
            return operatingSystem == .linux
        }
    }
}

public enum PlannerError: Error, Sendable, Equatable {
    case emptyIdea
    case emptyProjectName
    case noBuildTargets
    case incompatibleTarget(target: BuildTarget, operatingSystem: OperatingSystem)
    case filesystemUnavailable
    case processExecutionUnavailable
}
