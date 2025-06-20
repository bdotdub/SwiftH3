# SwiftH3

This is a simple library to interface with [H3](https://github.com/uber/h3), a hexagonal hierarchical geospatial indexing system.

## Installation

1. Add this to your `Package.swift` (or add via Xcode 11):
    * `.package(url: "https://github.com/bdotdub/SwiftH3.git", from: "0.1.0")`

## Examples

```swift
import SwiftH3

let coordinate = H3Coordinate(lat: 37.775, lon: -122.419)
let index = H3Index(coordinate: coordinate, resolution: 9)
print(index)
```

## Thanks

* To @twostraws for this great blog post about how to wrap C functions: https://hackingwithswift.com/articles/87/how-to-wrap-a-c-library-in-swift
* To @Uber for creating [H3](https://uber.github.io/h3)
