import XCTest
@testable import SwiftH3

final class H3IndexTests: XCTestCase {
    func testIsValid() {
        XCTAssertTrue(H3Index(0x8a2a10766d87fff).isValid())
        XCTAssertFalse(H3Index(0).isValid())
    }

    func testH3IndexToString() {
        let index = H3Index(0x8a2a10766d87fff)
        XCTAssertEqual(index.toString(), "8a2a10766d87fff")
    }

    func testResolution() {
        XCTAssertEqual(H3Index(0x8a2a10766d87fff).resolution, 10)
        XCTAssertEqual(H3Index(0).resolution, 0)
    }

    func testToCoord() {
        let coord = H3Index(0x8a2a10766d87fff).toCoordinate()
        XCTAssertLessThan(abs(coord.lat - 40.66121200787385), 0.0001)
        XCTAssertLessThan(abs(coord.lon + 73.94380522623717), 0.0001)
    }

    static var allTests = [
        ("testIsValid", testIsValid),
        ("testResolution", testResolution),
        ("testToCoord", testToCoord),
    ]
}
