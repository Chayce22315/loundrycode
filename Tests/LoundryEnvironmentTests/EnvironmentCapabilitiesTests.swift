import XCTest
@testable import LoundryEnvironment
import LoundryModels

final class EnvironmentCapabilitiesTests: XCTestCase {
    func testCapabilitiesDescribePolyglotEnvironment() {
        let capabilities = EnvironmentCapabilities(
            operatingSystem: .linux,
            shells: [.bash],
            languages: [.rust, .python, .typescript],
            networkAccess: .restricted
        )

        XCTAssertTrue(capabilities.languages.contains(.rust))
        XCTAssertTrue(capabilities.languages.contains(.python))
        XCTAssertEqual(capabilities.networkAccess, .restricted)
    }
}
