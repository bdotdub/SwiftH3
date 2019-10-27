import Ch3

public struct H3Index {

    private var value: UInt64

    public init(_ value: UInt64) {
        self.value = value
    }

    public init(coordinate: H3Coordinate, resolution: Int32) {
        var coord = GeoCoord(lat: degsToRads(coordinate.lat), lon: degsToRads(coordinate.lon))
        self.value = geoToH3(&coord, Int32(resolution))
    }

    public init(string: String) {
        var value: UInt64 = 0
        string.withCString { ptr in
            value = stringToH3(ptr)
        }
        self.value = value
    }

}

extension H3Index {

    public var resolution: Int {
        return Int(h3GetResolution(value))
    }

    public var isValid: Bool {
        return h3IsValid(value) == 1
    }

    public var coordinate: H3Coordinate {
        var coord = GeoCoord()
        h3ToGeo(value, &coord)
        return H3Coordinate(lat: radsToDegs(coord.lat), lon: radsToDegs(coord.lon))
    }

    public func kRingIndices(ringK: Int32) -> [H3Index] {
        var indices = [UInt64](repeating: 0, count: Int(maxKringSize(ringK)))
        indices.withUnsafeMutableBufferPointer { ptr in
            kRing(value, ringK, ptr.baseAddress)
        }
        return indices.map { H3Index($0) }
    }

}

extension H3Index: CustomStringConvertible {

    public var description: String {
        let cString = strdup("")
        h3ToString(value, cString, 17)
        return String(cString: cString!)
    }

}

extension H3Index: Equatable {}
