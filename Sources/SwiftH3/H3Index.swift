#include <string.h>
import Ch3

/// Represents an index in H3
public struct H3Index {

    private static let invalidIndex = 0

    private var value: UInt64

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
        var value: UInt64 = 0
        string.withCString { ptr in
            value = stringToH3(ptr)
        }
        self.value = value
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
        indices.withUnsafeMutableBufferPointer { ptr in
            kRing(value, ringK, ptr.baseAddress)
        }
        return indices.map { H3Index($0) }
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
        let cString = strdup("")
        h3ToString(value, cString, 17)
        return String(cString: cString!)
    }

}

extension H3Index: Equatable, Hashable {}
