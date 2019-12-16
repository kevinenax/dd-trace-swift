// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DDSwiftTracer",
    products: [
        .library(
            name: "DDSwiftTracer",
            targets: ["DDSwiftTracer"]),
    ],
    dependencies: [
         .package(url: "https://github.com/opentracing/opentracing-swift.git", .branch("master")),
         .package(url: "https://github.com/Miraion/Threading.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "DDSwiftTracer",
            dependencies: ["OpenTracing", "Threading"]),
        .testTarget(
            name: "DDSwiftTracerTests",
            dependencies: ["DDSwiftTracer"]),
    ]
)
