// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "optimizely_flutter_sdk",
    platforms: [.iOS("15.0")],
    products: [
        .library(name: "optimizely-flutter-sdk", targets: ["optimizely_flutter_sdk"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/optimizely/swift-sdk.git", exact: "6.0.1")
    ],
    targets: [
        .target(
            name: "optimizely_flutter_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Optimizely", package: "swift-sdk")
            ]
        )
    ]
)
