// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "optimizely_flutter_sdk",
    platforms: [.macOS("10.15")],
    products: [
        .library(name: "optimizely-flutter-sdk", targets: ["optimizely_flutter_sdk"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "optimizely_flutter_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
