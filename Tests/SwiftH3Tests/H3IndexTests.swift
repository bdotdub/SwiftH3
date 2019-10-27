import XCTest
@testable import SwiftH3

final class H3IndexTests: XCTestCase {
    func testStringToH3Index() {
        let coord = H3Index(string: "8a2a10766d87fff")
        XCTAssertEqual(coord, H3Index(0x8a2a10766d87fff))
    }

    func testCoordToH3Index() {
        let coord = H3Coordinate(lat: 40.661, lon: -73.944)
        XCTAssertEqual(H3Index(coordinate: coord, resolution: 10), H3Index(0x8a2a10766d87fff))
        XCTAssertEqual(H3Index(coordinate: coord, resolution: 5), H3Index(0x852a1077fffffff))
    }

    func testIsValid() {
        XCTAssertTrue(H3Index(0x8a2a10766d87fff).valid)
        XCTAssertFalse(H3Index(0).valid)
    }

    func testH3IndexToString() {
        let index = H3Index(0x8a2a10766d87fff)
        XCTAssertEqual(index.description, "8a2a10766d87fff")
    }

    func testResolution() {
        XCTAssertEqual(H3Index(0x8a2a10766d87fff).resolution, 10)
        XCTAssertEqual(H3Index(0).resolution, 0)
    }

    func testToCoord() {
        let coord = H3Index(0x8a2a10766d87fff).coordinate
        XCTAssertLessThan(abs(coord.lat - 40.66121200787385), 0.0001)
        XCTAssertLessThan(abs(coord.lon + 73.94380522623717), 0.0001)
    }

    func testKRingIndices() {
        let index = H3Index(0x8a2a10766d87fff)
        let expectedNeighbors = [
            0x8a2a10766d87fff, 0x8a2a10766db7fff, 0x8a2a10766d97fff, 0x8a2a10766d9ffff,
            0x8a2a10766d8ffff, 0x8a2a10766daffff, 0x8a2a10766da7fff
        ]
        let ringIndices = index.kRingIndices(k: 1)
        XCTAssertEqual(ringIndices, expectedNeighbors.map { H3Index(UInt64($0)) })
    }

    static var allTests = [
        ("testStringToH3Index", testStringToH3Index),
        ("testCoordToH3Index", testCoordToH3Index),
        ("testIsValid", testIsValid),
        ("testResolution", testResolution),
        ("testToCoord", testToCoord),
    ]
}
