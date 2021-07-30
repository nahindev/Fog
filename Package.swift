// swift-tools-version:5.4
import PackageDescription

let package = Package(name: "Fog")

package.platforms = [
    .macOS(.v10_15),
]

package.dependencies = [
    .package(url: "https://github.com/vapor/vapor", .upToNextMajor(from: "4.48.2")),
    .package(url: "https://github.com/grpc/grpc-swift", .upToNextMajor(from: "1.3.0")),
    .package(url: "https://github.com/Quick/Quick", .upToNextMajor(from: "4.0.0")),
    .package(url: "https://github.com/Quick/Nimble", .upToNextMajor(from: "9.2.0")),
]

package.targets = [
    .target(name: "Fog", dependencies: [
        .product(name: "Vapor", package: "vapor"),
    ]),
    .target(name: "FogGRPC", dependencies: [
        .target(name: "Fog"),
        .product(name: "GRPC", package: "grpc-swift"),
    ]),
    .target(name: "Example", dependencies: [
        .target(name: "Fog"),
    ]),
    .testTarget(name: "ExampleTests", dependencies: [
        .target(name: "Example"),
        .product(name: "XCTVapor", package: "vapor"),
        .product(name: "Quick", package: "Quick"),
        .product(name: "Nimble", package: "Nimble"),
    ]),
]

package.products = [
    .library(name: "Fog", targets: ["Fog"]),
    .library(name: "FogGRPC", targets: ["FogGRPC"]),
    .library(name: "Example", targets: ["Example"]),
]
