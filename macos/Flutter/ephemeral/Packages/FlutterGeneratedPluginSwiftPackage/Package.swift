// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "file_selector_macos", path: "../.packages/file_selector_macos-0.9.5+1"),
        .package(name: "firebase_core", path: "../.packages/firebase_core-4.14.0"),
        .package(name: "firebase_crashlytics", path: "../.packages/firebase_crashlytics-5.3.0"),
        .package(name: "firebase_messaging", path: "../.packages/firebase_messaging-16.6.0"),
        .package(name: "flutter_local_notifications", path: "../.packages/flutter_local_notifications-22.3.0"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.7"),
        .package(name: "url_launcher_macos", path: "../.packages/url_launcher_macos-3.2.6"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "file-selector-macos", package: "file_selector_macos"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-crashlytics", package: "firebase_crashlytics"),
                .product(name: "firebase-messaging", package: "firebase_messaging"),
                .product(name: "flutter-local-notifications", package: "flutter_local_notifications"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "url-launcher-macos", package: "url_launcher_macos"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
