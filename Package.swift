// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NotcursesSwift",
    platforms: [.macOS(.v11)],
    products: [
        .library(name: "NotcursesSwift", targets: ["NotcursesSwift"])
    ],
    targets: [
        .target(name: "NotcursesSwift", dependencies: ["notcurses"]),
        .target(name: "Demos", dependencies: ["NotcursesSwift"]),
        .target(name: "MouseDemo", dependencies: ["NotcursesSwift"]),
        .systemLibrary(
            name: "notcurses",
            pkgConfig: "notcurses",
            providers: [
                .brew(["notcurses"])
            ]
        )
    ]
)
