// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SliderView",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14),
        .macOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SliderView",
            targets: ["SliderView"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SliderView",
            dependencies: [],
            path: "Sources/SliderView"
        ),
        .testTarget(
            name: "SliderViewTests",
            dependencies: ["SliderView"],
            path: "Tests"
        ),
    ]
)
