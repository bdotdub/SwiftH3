// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftH3",
    products: [
        .library(
            name: "SwiftH3",
            targets: ["SwiftH3"]),
    ],
    dependencies: [
        .package(url: "https://github.com/bdotdub/Ch3.git", revision: "66333b035dcc936db729ba07684189db189bf893")
    ],
    targets: [
        .target(
            name: "SwiftH3",
            dependencies: ["Ch3"]),
        .testTarget(
            name: "SwiftH3Tests",
            dependencies: ["SwiftH3"]),
    ]
)
