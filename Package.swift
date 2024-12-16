// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TeleVideoCall",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "TeleVideoCall",
            targets: ["TeleVideoCall"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/aws/amazon-chime-sdk-ios-spm", branch: "main"),
        .package(url: "https://github.com/cometchat/chat-sdk-ios.git", from: "4.0.54"),
        .package(url: "https://github.com/ninjaprox/NVActivityIndicatorView.git", from: "5.2.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", from: "5.1.0")
    ],
    targets: [
        .target(
            name: "TeleVideoCall",
            dependencies: [
                .product(name: "AmazonChimeSDK", package: "amazon-chime-sdk-ios-spm"),
                .product(name: "CometChatSDK", package: "chat-sdk-ios"),
                .product(name: "NVActivityIndicatorView", package: "NVActivityIndicatorView"),
                .product(name: "SDWebImage", package: "SDWebImage")
            ],
            path: "Sources/TeleVideoCall" ,
            resources: [
                .process("TelemechanicVideoMain.storyboard"),
                .process("Font/ttf")
                       ]
        ),
        .testTarget(
            name: "TeleVideoCallTests",
            dependencies: ["TeleVideoCall"],
            path: "Tests/TeleVideoCallTests"
        ),
    ]
)

