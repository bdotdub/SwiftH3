import XCTest
@testable import SwiftH3

final class H3IndexTests: XCTestCase {

    // MARK: Initialization

    func testStringToH3Index() {
        let coord = H3Index(string: "8a2a10766d87fff")
        XCTAssertEqual(coord, H3Index(0x8a2a10766d87fff))
    }

    func testCoordToH3Index() {
        let coord = H3Coordinate(lat: 40.661, lon: -73.944)
        XCTAssertEqual(H3Index(coordinate: coord, resolution: 10), H3Index(0x8a2a10766d87fff))
        XCTAssertEqual(H3Index(coordinate: coord, resolution: 5), H3Index(0x852a1077fffffff))
    }

    // MARK: Properties

    func testIsValid() {
        XCTAssertTrue(H3Index(0x8a2a10766d87fff).isValid)
        XCTAssertFalse(H3Index(0).isValid)
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

    // MARK: Traversal

    func testKRingIndices() {
        let index = H3Index(0x8a2a10766d87fff)
        let expectedNeighbors = [
            0x8a2a10766d87fff, 0x8a2a10766db7fff, 0x8a2a10766d97fff, 0x8a2a10766d9ffff,
            0x8a2a10766d8ffff, 0x8a2a10766daffff, 0x8a2a10766da7fff
        ]
        let ringIndices = index.kRingIndices(ringK: 1)
        XCTAssertEqual(ringIndices, expectedNeighbors.map { H3Index(UInt64($0)) })
    }

    // MARK: Hierarchy

    func testParent() {
        let index = H3Index(0x8a2a10766d87fff)
        XCTAssertEqual(index.parent(at: 4), H3Index(0x842a107ffffffff))
        XCTAssertEqual(index.parent(at: 1), H3Index(0x812a3ffffffffff))
        XCTAssertEqual(index.parent(at: 11), nil)
    }

    func testDirectParent() {
        let index = H3Index(0x8a2a10766d87fff)
        XCTAssertEqual(index.directParent, H3Index(0x892a10766dbffff))
        XCTAssertEqual(index.directParent, index.parent(at: index.resolution - 1))

        let res1Index = index.parent(at: 0)
        XCTAssertEqual(res1Index!.directParent, nil)
    }

    func testChildren() {
        let index = H3Index(0x8a2a10766d87fff)
        XCTAssertEqual(index.children(at: 9), [])

        let expectedRes11 = [
            0x8b2a10766d80fff, 0x8b2a10766d81fff, 0x8b2a10766d82fff, 0x8b2a10766d83fff,
            0x8b2a10766d84fff, 0x8b2a10766d85fff, 0x8b2a10766d86fff
        ].map { H3Index($0) }
        XCTAssertEqual(index.children(at: 11), expectedRes11)

        let expectedRes12 = [
            0x8c2a10766d801ff, 0x8c2a10766d803ff, 0x8c2a10766d805ff, 0x8c2a10766d807ff,
            0x8c2a10766d809ff, 0x8c2a10766d80bff, 0x8c2a10766d80dff, 0x8c2a10766d811ff,
            0x8c2a10766d813ff, 0x8c2a10766d815ff, 0x8c2a10766d817ff, 0x8c2a10766d819ff,
            0x8c2a10766d81bff, 0x8c2a10766d81dff, 0x8c2a10766d821ff, 0x8c2a10766d823ff,
            0x8c2a10766d825ff, 0x8c2a10766d827ff, 0x8c2a10766d829ff, 0x8c2a10766d82bff,
            0x8c2a10766d82dff, 0x8c2a10766d831ff, 0x8c2a10766d833ff, 0x8c2a10766d835ff,
            0x8c2a10766d837ff, 0x8c2a10766d839ff, 0x8c2a10766d83bff, 0x8c2a10766d83dff,
            0x8c2a10766d841ff, 0x8c2a10766d843ff, 0x8c2a10766d845ff, 0x8c2a10766d847ff,
            0x8c2a10766d849ff, 0x8c2a10766d84bff, 0x8c2a10766d84dff, 0x8c2a10766d851ff,
            0x8c2a10766d853ff, 0x8c2a10766d855ff, 0x8c2a10766d857ff, 0x8c2a10766d859ff,
            0x8c2a10766d85bff, 0x8c2a10766d85dff, 0x8c2a10766d861ff, 0x8c2a10766d863ff,
            0x8c2a10766d865ff, 0x8c2a10766d867ff, 0x8c2a10766d869ff, 0x8c2a10766d86bff,
            0x8c2a10766d86dff
        ].map { H3Index($0) }
        XCTAssertEqual(index.children(at: 12), expectedRes12)
    }

    func testCenterChild() {
        let index = H3Index(0x8a2a10766d87fff)
        XCTAssertEqual(index.centerChild(at: 11), H3Index(0x8b2a10766d80fff))
        XCTAssertEqual(index.centerChild(at: 15), H3Index(0x8f2a10766d80000))
        XCTAssertEqual(index.centerChild(at: 9), nil)
    }

    func testDirectCenterChild() {
        let index = H3Index(0x8a2a10766d87fff)
        XCTAssertEqual(index.directCenterChild, H3Index(0x8b2a10766d80fff))
        XCTAssertEqual(index.directCenterChild, index.centerChild(at: index.resolution + 1))

        let res15Index = index.centerChild(at: 15)
        XCTAssertEqual(res15Index!.directCenterChild, nil)
    }

    static var allTests = [
        ("testStringToH3Index", testStringToH3Index),
        ("testCoordToH3Index", testCoordToH3Index),
        ("testIsValid", testIsValid),
        ("testResolution", testResolution),
        ("testToCoord", testToCoord),
    ]
}
