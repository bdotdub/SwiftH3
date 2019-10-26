import XCTest
@testable import SwiftH3

final class SwiftH3Tests: XCTestCase {
    func testH3CoordinateToIndex() {
        let coord = H3Coordinate(lat: 40.661, lon: -73.944)
        XCTAssertEqual(coord.toIndex(resolution: 10), H3Index(622236751692857343))
        XCTAssertEqual(coord.toIndex(resolution: 5), H3Index(599718753978023935))
    }

    func testH3IndexToString() {
        let index = H3Index(622236751692857343)
        XCTAssertEqual(index.toString(), "8a2a10766d87fff")
    }

    func testH3IndexIsValid() {
        XCTAssertTrue(H3Index(622236751692857343).isValid())
        XCTAssertFalse(H3Index(0).isValid())
    }

    func testH3IndexResolution() {
        XCTAssertEqual(H3Index(622236751692857343).resolution, 10)
        XCTAssertEqual(H3Index(0).resolution, 0)
    }

    func testH3IndexToCoord() {
        let coord = H3Index(622236751692857343).toCoordinate()
        XCTAssertLessThan(abs(coord.lat - 40.66121200787385), 0.0001)
        XCTAssertLessThan(abs(coord.lon + 73.94380522623717), 0.0001)
    }

    func testStringToH3Coord() {
        let coord = "8a2a10766d87fff".toH3Index()
        XCTAssertEqual(coord, 622236751692857343)
    }

    static var allTests = [
        ("testH3CoordinateToIndex", testH3CoordinateToIndex),
        ("testH3IndexToString", testH3IndexToString),
        ("testH3IndexIsValid", testH3IndexIsValid),
        ("testH3IndexResolution", testH3IndexResolution),
        ("testStringToH3Coord", testStringToH3Coord),
    ]
}
