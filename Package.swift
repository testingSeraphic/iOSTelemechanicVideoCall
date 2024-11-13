// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TeleVideoCall",
    platforms: [
        .iOS(.v15)  // Ensure it's targeting iOS
    ],
    products: [
        .library(
            name: "TeleVideoCall",         // This is the product name
            targets: ["TeleVideoCall"]     // This is the target that builds the library
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/aws/amazon-chime-sdk-ios-spm", branch: "main"),
    ],
    targets: [
        .target(
            name: "TeleVideoCall",  // This is the target that builds the library
            dependencies: [
                .product(name: "AmazonChimeSDK", package: "amazon-chime-sdk-ios-spm")
            ],
            path: "Sources/TeleVideoCall" , // Path to your source code folder
            resources: [
                .process("TelemechanicVideoMain.storyboard"),
                .process("Font/ttf")
                       ]
        ),
        .testTarget(
            name: "TeleVideoCallTests",  // This is the test target
            dependencies: ["TeleVideoCall"],
            path: "Tests/TeleVideoCallTests"  // Path for test files
        ),
    ]
)

