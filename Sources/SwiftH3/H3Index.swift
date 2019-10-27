import Ch3

struct H3Index {

    fileprivate let value: UInt64

    init(_ value: UInt64) {
        self.value = value
    }

}

extension H3Index {

    var resolution: Int {
        return Int(h3GetResolution(value))
    }

    var valid: Bool {
        return h3IsValid(value) == 1
    }

    var coordinate: H3Coordinate {
        var coord = GeoCoord()
        h3ToGeo(value, &coord)
        return H3Coordinate(lat: radsToDegs(coord.lat), lon: radsToDegs(coord.lon))
    }

}

extension H3Index: CustomStringConvertible {

    var description: String {
        let cString = strdup("")
        h3ToString(value, cString, 17)
        return String(cString: cString!)
    }

}

extension H3Index: Equatable {

    static func == (lhs: H3Index, rhs: H3Index) -> Bool {
        return lhs.value == rhs.value
    }

}
