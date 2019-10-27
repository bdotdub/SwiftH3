import XCTest
@testable import SwiftH3

final class StringExtensionsTests: XCTestCase {
    func testStringToH3Coord() {
        let coord = "8a2a10766d87fff".toH3Index()
        XCTAssertEqual(coord, H3Index(0x8a2a10766d87fff))
    }

    static var allTests = [
        ("testStringToH3Coord", testStringToH3Coord),
    ]
}
