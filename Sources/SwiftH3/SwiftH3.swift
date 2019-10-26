#if canImport(Darwin)
import Darwin
import Ch3mac
#endif

import Foundation

struct H3Coordinate {

    private var internalCoordinate: GeoCoord

    init(lat: Double, lon: Double) {
        internalCoordinate = GeoCoord(lat: lat, lon: lon)
    }
}

extension H3Coordinate {

    func toIndex(resolution: Int) -> H3Index {
        var coord = internalCoordinate
        return H3Index(geoToH3(&coord, Int32(resolution)))
    }
}

typealias H3Index = UInt64

extension H3Index {

    func toString() -> String {
        let cString = strdup("")
        h3ToString(self, cString, 17)
        return String(cString: cString!)
    }

    func isValid() -> Bool {
        return h3IsValid(self) == 1
    }

}