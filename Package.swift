// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "LCInfiniteScrollView",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "LCInfiniteScrollView", targets: ["LCInfiniteScrollView"])
    ],
    targets: [
        .target(
            name: "LCInfiniteScrollView",
            path: "Sources",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        )
    ]
)
