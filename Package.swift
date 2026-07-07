// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "LoopScroll",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "LoopScroll", targets: ["LoopScroll"])
    ],
    targets: [
        .target(
            name: "LoopScroll",
            path: "Sources",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        )
    ]
)
