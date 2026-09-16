import Foundation
import LoundryModels

public struct ModelRequest: Sendable, Hashable {
    public let project: LoundryProject
    public let instruction: String

    public init(project: LoundryProject, instruction: String) {
        self.project = project
        self.instruction = instruction
    }
}

public enum ModelEvent: Sendable, Hashable {
    case text(String)
    case file(path: String, contents: String)
    case command(EnvironmentCommand)
    case finished
}

public protocol ModelProvider: Sendable {
    var providerID: String { get }
    var modelID: String { get }
    func generate(for request: ModelRequest) -> AsyncThrowingStream<ModelEvent, Error>
}

public struct UnavailableModelProvider: ModelProvider {
    public let providerID = "unconfigured"
    public let modelID = "none"

    public init() {}

    public func generate(for request: ModelRequest) -> AsyncThrowingStream<ModelEvent, Error> {
        AsyncThrowingStream { continuation in
            continuation.finish(throwing: ModelProviderError.notConfigured)
        }
    }
}

public enum ModelProviderError: Error, Sendable, Equatable {
    case notConfigured
}
