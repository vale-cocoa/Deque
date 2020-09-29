import XCTest
@testable import Deque

final class DequeTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Deque().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
