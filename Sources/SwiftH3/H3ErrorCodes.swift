//
//  H3ErrorCodes.swift
//  SwiftH3
//
//  Created by Benny Wong on 3/26/25.
//

import Ch3

enum H3ErrorCodes: UInt32 {
    case success = 0 // Success (no error)
    case failed = 1 // The operation failed but a more specific error is not available
    case domain = 2 // Argument was outside of acceptable range (when a more specific error code is not available)
    case latLngDomain = 3 // Latitude or longitude arguments were outside of acceptable range
    case resDomain = 4 // Resolution argument was outside of acceptable range
    case cellInvalid = 5 // `H3Index` cell argument was not valid
    case dirEdgeInvalid = 6 // `H3Index` directed edge argument was not valid
    case undirEdgeInvalid = 7 // `H3Index` undirected edge argument was not valid
    case vertexInvalid = 8 // `H3Index` vertex argument was not valid
    case pentagon = 9 // Pentagon distortion was encountered which the algorithm could not handle it
    case duplicateInput = 10 // Duplicate input was encountered in the arguments and the algorithm could not handle it
    case notNeighbors = 11 // `H3Index` cell arguments were not neighbors
    case resMismatch = 12 // `H3Index` cell arguments had incompatible resolutions
    case memoryAlloc = 13 // Necessary memory allocation failed
    case memoryBounds = 14 // Bounds of provided memory were not large enough
    case optionInvalid = 15 // Mode or flags argument was not valid.
}

extension Ch3.H3Error {
    var code: H3ErrorCodes {
        H3ErrorCodes(rawValue: self) ?? .success
    }
}
