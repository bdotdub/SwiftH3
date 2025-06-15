import Ch3

/// Represents a coordinate based on latitude and longitude
public struct H3Coordinate {

    /// The latitude
    public let lat: Double

    /// The longitude
    public let lon: Double

    /**
     Initializes the coordinates given a latitude and longitude

     - Parameters:
        - lat: The latitude
        - lon: The longitude
     */
    public init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
    }

    public var latLng: LatLng {
        Ch3.LatLng(lat: degsToRads(lat), lng: degsToRads(lon))
    }
}

extension H3Coordinate: Equatable {

    public static func == (lhs: H3Coordinate, rhs: H3Coordinate) -> Bool {
        lhs.lat == rhs.lat && lhs.lon == rhs.lon
    }

}
