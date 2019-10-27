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

}
