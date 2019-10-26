#if canImport(Darwin)
import Darwin
import Ch3mac
#endif

import Foundation

struct H3Coordinate {

    let lat: Double
    let lon: Double

}

extension H3Coordinate {

    func toIndex(resolution: Int) -> H3Index {
        var coord = GeoCoord(lat: lat, lon: lon)
        return H3Index(geoToH3(&coord, Int32(resolution)))
    }
}

typealias H3Index = UInt64

extension H3Index {

    var resolution: Int {
        get {
            return Int(h3GetResolution(self))
        }
    }

    func toString() -> String {
        let cString = strdup("")
        h3ToString(self, cString, 17)
        return String(cString: cString!)
    }

    func isValid() -> Bool {
        return h3IsValid(self) == 1
    }

    func toCoordinate() -> H3Coordinate {
        var coord = GeoCoord()
        h3ToGeo(self, &coord)
        return H3Coordinate(lat: coord.lat, lon: coord.lon)
    }

}

extension String {
    func toH3Coordinate() -> H3Coordinate {
        let str = strdup("")
        let index = stringToH3(str)
        return index.toCoordinate()
    }
}