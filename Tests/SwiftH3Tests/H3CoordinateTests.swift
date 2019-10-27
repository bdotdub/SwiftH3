import XCTest
@testable import SwiftH3

final class H3CoordinateTests: XCTestCase {
    func testToIndex() {
        let coord = H3Coordinate(lat: 40.661, lon: -73.944)
        XCTAssertEqual(coord.toIndex(resolution: 10), H3Index(622236751692857343))
        XCTAssertEqual(coord.toIndex(resolution: 5), H3Index(599718753978023935))
    }

    static var allTests = [
        ("testToIndex", testToIndex),
    ]
}
