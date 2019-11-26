import XCTest
@testable import AssetChecker

final class AssetCheckerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(AssetChecker().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
