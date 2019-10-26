import XCTest
@testable import SwiftH3

final class SwiftH3Tests: XCTestCase {
    func testH3CoordinateToIndex() {
        let coord = H3Coordinate(lat: 40.661, lon: -73.944)
        XCTAssertEqual(coord.toIndex(resolution: 10), H3Index(623400371267010559))
        XCTAssertEqual(coord.toIndex(resolution: 5), H3Index(600882373361401855))
    }

    func testH3IndexToString() {
        let index = H3Index(623400371267010559)
        XCTAssertEqual(index.toString(), "8a6c355b2377fff")
    }

    func testH3IndexIsValid() {
        XCTAssertTrue(H3Index(623400371267010559).isValid())
        XCTAssertFalse(H3Index(0).isValid())
    }

    func testH3IndexResolution() {
        XCTAssertEqual(H3Index(623400371267010559).resolution, 10)
        XCTAssertEqual(H3Index(0).resolution, 0)
    }

    func testH3IndexToCoord() {
        let coord = H3Index(623400371267010559).toCoordinate()
        XCTAssertLessThan(abs(coord.lat), 0.0001)
        XCTAssertLessThan(abs(coord.lon), 0.0001)
    }

    static var allTests = [
        ("testH3CoordinateToIndex", testH3CoordinateToIndex),
        ("testH3IndexToString", testH3IndexToString),
        ("testH3IndexIsValid", testH3IndexIsValid),
        ("testH3IndexResolution", testH3IndexResolution),
    ]
}
