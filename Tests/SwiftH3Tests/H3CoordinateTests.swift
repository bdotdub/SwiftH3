import XCTest
@testable import SwiftH3

final class H3CoordinateTests: XCTestCase {
    func testToIndex() {
        let coord = H3Coordinate(lat: 40.661, lon: -73.944)
        XCTAssertEqual(coord.toIndex(resolution: 10), H3Index(0x8a2a10766d87fff))
        XCTAssertEqual(coord.toIndex(resolution: 5), H3Index(0x852a1077fffffff))
    }

    static var allTests = [
        ("testToIndex", testToIndex),
    ]
}
