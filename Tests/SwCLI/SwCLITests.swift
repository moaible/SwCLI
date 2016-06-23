import XCTest
@testable import SwCLI

class SwCLITests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(SwCLI().text, "Hello, World!")
    }


    static var allTests : [(String, (SwCLITests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
