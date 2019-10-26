import XCTest
@testable import SwiftH3

final class SwiftH3Tests: XCTestCase {
    func testH3CoordinateToIndex() {
        let coord = H3Coordinate(lat: 0, lon: 0)
        XCTAssertEqual(coord.toIndex(resolution: 10), H3Index(623560421467684863))
        XCTAssertEqual(coord.toIndex(resolution: 5), H3Index(601042424243945471))
    }

    func testH3IndexToString() {
        let index = H3Index(623560421467684863)
        XCTAssertEqual(index.toString(), "8a754e64992ffff")
    }

    func testH3IndexIsValid() {
        XCTAssertTrue(H3Index(623560421467684863).isValid())
        XCTAssertFalse(H3Index(0).isValid())
    }

    func testH3IndexResolution() {
        XCTAssertEqual(H3Index(623560421467684863).resolution, 10)
        XCTAssertEqual(H3Index(0).resolution, 0)
    }

    static var allTests = [
        ("testH3CoordinateToIndex", testH3CoordinateToIndex),
        ("testH3IndexToString", testH3IndexToString),
        ("testH3IndexIsValid", testH3IndexIsValid),
        ("testH3IndexResolution", testH3IndexResolution),
    ]
}
