import Ch3

struct H3Coordinate {

    let lat: Double
    let lon: Double

}

extension H3Coordinate {

    func toIndex(resolution: Int) -> H3Index {
        var coord = GeoCoord(lat: degsToRads(lat), lon: degsToRads(lon))
        return H3Index(geoToH3(&coord, Int32(resolution)))
    }
}
