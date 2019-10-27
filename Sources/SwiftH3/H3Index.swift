import Ch3

typealias H3Index = UInt64

extension H3Index {

    var resolution: Int {
        return Int(h3GetResolution(self))
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
        return H3Coordinate(lat: radsToDegs(coord.lat), lon: radsToDegs(coord.lon))
    }

}
