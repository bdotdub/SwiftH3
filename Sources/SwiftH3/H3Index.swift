import Ch3

/// Represents an index in H3
public struct H3Index {

    private static let invalidIndex = 0

    private var value: UInt64

    // MARK: - Initializers

    /**
     Initializes using a 64-bit integer

     - Parameter value: 64-bit integer representing index
     */
    public init(_ value: UInt64) {
        self.value = value
    }

    /**
     Initializes using a coordinate at a particular resolution.

     - Parameters:
        - coordinate: The coordinate
        - resolution: The resolution
    */
    public init(coordinate: H3Coordinate, resolution: Int32) {
        var coord = GeoCoord(lat: degsToRads(coordinate.lat), lon: degsToRads(coordinate.lon))
        self.value = geoToH3(&coord, Int32(resolution))
    }

    /**
     Initializes using the string representation of an index.
     For example: "842a107ffffffff"

     - Parameter string: The string representing the hex value of the int
     */
    public init(string: String) {
        let value = string.withCString { cString in
            stringToH3(cString)
        }
        guard value != 0 else {
            fatalError("Invalid H3 index string: \(string)")
        }
        self.value = value
    }

}
extension H3Index {
    
    /// Returns the cell boundary in spherical coordinates for an H3 index.
    ///
    /// - Returns: The boundary of the H3 cell in spherical coordinates.
    public func boundary() -> [H3Coordinate] {
        var gb = GeoBoundary()
        h3ToGeoBoundary(value, &gb)
        
        var coordinates: [H3Coordinate] = []
        
        switch gb.numVerts {
        case 10:
            coordinates.append(H3Coordinate(lat: radsToDegs(gb.verts.9.lat), lon: radsToDegs(gb.verts.9.lon)))
            fallthrough
        case 9:
            coordinates.append(H3Coordinate(lat: radsToDegs(gb.verts.8.lat), lon: radsToDegs(gb.verts.8.lon)))
            fallthrough
        case 8:
            coordinates.append(H3Coordinate(lat: radsToDegs(gb.verts.7.lat), lon: radsToDegs(gb.verts.7.lon)))
            fallthrough
        case 7:
            coordinates.append(H3Coordinate(lat: radsToDegs(gb.verts.6.lat), lon: radsToDegs(gb.verts.6.lon)))
            fallthrough
        case 6:
            coordinates.append(H3Coordinate(lat: radsToDegs(gb.verts.5.lat), lon: radsToDegs(gb.verts.5.lon)))
            fallthrough
        case 5:
            coordinates.append(H3Coordinate(lat: radsToDegs(gb.verts.4.lat), lon: radsToDegs(gb.verts.4.lon)))
            fallthrough
        case 4:
            coordinates.append(H3Coordinate(lat: radsToDegs(gb.verts.3.lat), lon: radsToDegs(gb.verts.3.lon)))
            fallthrough
        case 3:
            coordinates.append(H3Coordinate(lat: radsToDegs(gb.verts.2.lat), lon: radsToDegs(gb.verts.2.lon)))
            fallthrough
        case 2:
            coordinates.append(H3Coordinate(lat: radsToDegs(gb.verts.1.lat), lon: radsToDegs(gb.verts.1.lon)))
            fallthrough
        case 1:
            coordinates.append(H3Coordinate(lat: radsToDegs(gb.verts.0.lat), lon: radsToDegs(gb.verts.0.lon)))
        default:
            break
        }
        
        return coordinates
    }
    
}

// MARK: Properties

extension H3Index {

    /// The resolution of the index
    public var resolution: Int {
        return Int(h3GetResolution(value))
    }

    /// Indicates whether this is a valid H3 index
    public var isValid: Bool {
        return h3IsValid(value) == 1
    }

    /// The coordinate that this index represents
    public var coordinate: H3Coordinate {
        var coord = GeoCoord()
        h3ToGeo(value, &coord)
        return H3Coordinate(lat: radsToDegs(coord.lat), lon: radsToDegs(coord.lon))
    }

}

// MARK: Traversal

extension H3Index {

    /**
     Returns the indices that are `ringK` "rings" from the index.

     - Parameters:
        - ringK: The numbers of rings to expand to
     - Returns: A list of indices. Can be empty.
     */
    public func kRingIndices(ringK: Int32) -> [H3Index] {
        var indices = [UInt64](repeating: 0, count: Int(maxKringSize(ringK)))
        kRing(value, ringK, &indices)
        return indices.compactMap { $0 == 0 ? nil : H3Index($0) }
    }

}

// MARK: Hierarchy

extension H3Index {

    /// The index that is one resolution lower than the index.
    /// Can be nil if invalid.
    public var directParent: H3Index? {
        return parent(at: resolution - 1)
    }

    /// The index that is one resolution higher than the index.
    /// Can be nil if invalid.
    public var directCenterChild: H3Index? {
        return centerChild(at: resolution + 1)
    }

    /// The index for the parent at the resolution `resolution`.
    ///
    /// - Parameter resolution: The resolution for the parent
    /// - Returns: The parent index at that resolution.
    ///            Can be nil if invalid
    public func parent(at resolution: Int) -> H3Index? {
        let val = h3ToParent(value, Int32(resolution))
        return val == H3Index.invalidIndex ? nil : H3Index(val)
    }

    /// The index for the parent at the resolution `resolution`.
    ///
    /// - Parameter resolution: The resolution for the parent
    /// - Returns: The parent index at that resolution.
    ///            Can be nil if invalid
    public func children(at resolution: Int) -> [H3Index] {
        var children = [UInt64](
            repeating: 0,
            count: Int(maxH3ToChildrenSize(value, Int32(resolution)))
        )
        children.withUnsafeMutableBufferPointer { ptr in
            h3ToChildren(value, Int32(resolution), ptr.baseAddress)
        }
        return children
            .filter { $0 != 0 }
            .map { H3Index($0) }
    }

    /// The index for the child directly below the current index
    /// at the resolution `resolution`.
    ///
    /// - Parameter resolution: The resolution for the parent
    /// - Returns: The center child index at that resolution.
    ///            Can be nil if invalid
    public func centerChild(at resolution: Int) -> H3Index? {
        let index = h3ToCenterChild(value, Int32(resolution))
        return index == H3Index.invalidIndex ? nil : H3Index(index)
    }

}

extension H3Index: CustomStringConvertible {

    /// String description of the index
    public var description: String {
        var buffer = [CChar](repeating: 0, count: 17)
        buffer.withUnsafeMutableBufferPointer { ptr in
            h3ToString(value, ptr.baseAddress, 17)
        }
        return String(cString: buffer)
    }

}

extension H3Index: Equatable, Hashable {}
