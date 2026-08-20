// swift-tools-version: 5.9
//
// NOTE: This package lives in ios/optimizely-flutter-sdk/ (hyphens).
// A symlink ios/optimizely_flutter_sdk (underscores) points here so that
// Flutter's SPM integration can discover the Package.swift. The hyphenated
// directory name is required because SPM normalizes package identity by
// replacing underscores with hyphens — the directory name must match.
//
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
