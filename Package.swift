// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RemoteComposeUI",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RemoteComposeUI",
            targets: ["RemoteComposeUI"]
        ),
        .executable(name: "rcdump", targets: ["rcdump"])
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RemoteComposeUI",
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
        .executableTarget(name: "rcdump", dependencies: ["RemoteComposeUI"]),
        .testTarget(
            name: "RemoteComposeUITests",
            dependencies: ["RemoteComposeUI"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
        ),
    ]
)
