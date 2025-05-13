// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUISuperView",
    platforms: [
           .iOS(.v15),
       ],
    products: [
        .library(
            name: "SwiftUISuperView",
            targets: ["SwiftUISuperView"]),
    ],
    targets: [
        .target(
            name: "SwiftUISuperView"),
        .testTarget(
            name: "SwiftUISuperViewTests",
            dependencies: ["SwiftUISuperView"]
        ),
    ]
)
