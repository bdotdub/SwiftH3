import Ch3
import Darwin

/// Represents an index in H3
public struct H3Index {

    private static let invalidIndex = 0

    private var value: Ch3.H3Index

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
        var latLng = LatLng(lat: degsToRads(coordinate.lat), lng: degsToRads(coordinate.lon))
        var index: Ch3.H3Index = 0
        latLngToCell(&latLng, Int32(resolution), &index)
        self.value = index
    }

    /**
     Initializes using the string representation of an index.
     For example: "842a107ffffffff"

     - Parameter string: The string representing the hex value of the int
     */
    public init?(string: String) {
        var error: Ch3.H3Error = 0
        var value: Ch3.H3Index = 0
        string.withCString { ptr in
            error = stringToH3(ptr, &value)
        }
        if error.code != .success {
            return nil
        }
        self.value = value
    }

}

// MARK: Properties

extension H3Index {

    /// The resolution of the index
    public var resolution: Int {
        return Int(getResolution(value))
    }

    /// Indicates whether this is a valid H3 index
    public var isValid: Bool {
        return isValidCell(value) != 0
    }

    /// The coordinate that this index represents
    public var coordinate: H3Coordinate? {
        var coord = LatLng()
        let error = cellToLatLng(value, &coord)
        if error.code != .success {
            return nil
        }
        return H3Coordinate(lat: radsToDegs(coord.lat), lon: radsToDegs(coord.lng))
    }

    /// The vertices of the index
    public var vertices: [H3Coordinate] {
        var cellBoundary = Ch3.CellBoundary()
        let error = cellToBoundary(value, &cellBoundary)
        if error.code != .success {
            return []
        }
        let vertsArray: [LatLng] = withUnsafePointer(to: cellBoundary.verts) {
            let ptr = UnsafeRawPointer($0).assumingMemoryBound(to: LatLng.self)
            return Array(UnsafeBufferPointer(start: ptr, count: Int(cellBoundary.numVerts)))
        }
        return vertsArray.map { latLng in
            H3Coordinate(lat: radsToDegs(latLng.lat), lon: radsToDegs(latLng.lng))
        }
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
    public func kRingIndices(ringK: Int32) throws -> [H3Index] {
        var maxSize: Int64 = 0
        let maxGridError = maxGridDiskSize(Int32(ringK), &maxSize)
        if maxGridError.code != .success {
            throw maxGridError.code
        }

        var indices = [UInt64](repeating: 0, count: Int(maxSize))
        var gridDiskError: H3Error = 0
        indices.withUnsafeMutableBufferPointer { ptr in
            gridDiskError = gridDisk(value, ringK, ptr.baseAddress)
        }
        if gridDiskError.code != .success {
            throw gridDiskError.code
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
        var parent: Ch3.H3Index = 0
        let error = cellToParent(value, Int32(resolution), &parent)
        if error.code != .success {
            return nil
        }
        return H3Index(parent)
    }

    /// The index for the parent at the resolution `resolution`.
    ///
    /// - Parameter resolution: The resolution for the parent
    /// - Returns: The parent index at that resolution.
    ///            Can be nil if invalid
    public func children(at resolution: Int) throws -> [H3Index] {
        var maxChildren: Int64 = 0
        let maxChildrenError = cellToChildrenSize(value, Int32(resolution), &maxChildren)
        if maxChildrenError.code != .success {
            throw maxChildrenError.code
        }

        var error: H3Error
        var children = [UInt64](
            repeating: 0,
            count: Int(maxChildren)
        )
        error = cellToChildren(value, Int32(resolution), &children)
        if error.code != .success {
            throw error.code
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
        let memory = UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        defer { memory.deallocate() }
        guard cellToCenterChild(value, Int32(resolution), memory) == 0 else {
            return nil
        }

        let index = memory.pointee
        return index == H3Index.invalidIndex ? nil : H3Index(index)
    }
}

public class H3Polygon {
    private var loop: [Ch3.LatLng]
    private var holes: [[Ch3.LatLng]]

    internal func withGeoPolygon<T>(_ body: (inout GeoPolygon) -> T) -> T {
        return loop.withUnsafeMutableBufferPointer { loopPtr in
            var holeLoops: [GeoLoop] = []
            holeLoops.reserveCapacity(holes.count)
            for var hole in holes {
                let loop = hole.withUnsafeMutableBufferPointer { ptr in
                    GeoLoop(numVerts: Int32(ptr.count), verts: ptr.baseAddress)
                }
                holeLoops.append(loop)
            }

            var holeLoopsCopy = holeLoops
            return holeLoopsCopy.withUnsafeMutableBufferPointer { holesPtr in
                var polygon = GeoPolygon(
                    geoloop: GeoLoop(
                        numVerts: Int32(loopPtr.count),
                        verts: loopPtr.baseAddress
                    ),
                    numHoles: Int32(holeLoops.count),
                    holes: holesPtr.baseAddress
                )
                return body(&polygon)
            }
        }
    }

    public init(loop: [H3Coordinate], holes: [[H3Coordinate]] = []) {
        self.loop = loop.map(\.latLng)
        self.holes = holes.map { $0.map(\.latLng) }
    }
}

extension Array where Element == H3Coordinate {

    var geoLoop: GeoLoop {
        var verts = map(\.latLng)
        return verts.withUnsafeMutableBufferPointer { ptr in
            return GeoLoop(
                numVerts: Int32(count),
                verts: ptr.baseAddress
            )
        }

    }
}

extension H3Index {

    public static func polygonToCells(polygon: H3Polygon, resolution: Int) -> [H3Index] {
        return polygon.withGeoPolygon { geoPolygon in
            var polygon = geoPolygon

            var maxCellsSize: Int64 = 0
            let sizeError = maxPolygonToCellsSize(&polygon, Int32(resolution), 0, &maxCellsSize)
            if sizeError.code != .success {
                return []
            }

            var cells = [UInt64](repeating: 0, count: Int(maxCellsSize))
            let error = Ch3.polygonToCells(&polygon, Int32(resolution), 0, &cells)
            if error.code != .success {
                return []
            }

            return cells.map(H3Index.init).filter(\.isValid)
        }
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
