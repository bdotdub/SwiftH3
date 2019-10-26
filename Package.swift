// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftH3",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "SwiftH3",
            targets: ["SwiftH3"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "../Ch3", from: "0.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftH3",
            dependencies: []),
        .testTarget(
            name: "SwiftH3Tests",
            dependencies: ["SwiftH3"]),
    ]
)
