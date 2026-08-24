// swift-tools-version: 5.9
// ObjC files (OptimizelyFlutterSdkPlugin.m/.h) are excluded from the SPM
// target because SPM does not support mixed Swift/ObjC in a single target.
// They remain on disk for CocoaPods builds, which still use them.

import PackageDescription

let package = Package(
    name: "optimizely_flutter_sdk",
    platforms: [.iOS("10.0")],
    products: [
        .library(name: "optimizely-flutter-sdk", targets: ["optimizely_flutter_sdk"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/optimizely/swift-sdk.git", exact: "5.4.2")
    ],
    targets: [
        .target(
            name: "optimizely_flutter_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Optimizely", package: "swift-sdk")
            ],
            exclude: ["OptimizelyFlutterSdkPlugin.m", "include"]
        )
    ]
)
