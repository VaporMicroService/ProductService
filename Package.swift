// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "ProductService",
    products: [
        .library(name: "ProductService", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        // 🔵 Swift PostGIS built for FluentPostgreSQL.
        .package(url: "https://github.com/plarson/fluent-postgis.git", .branch("master")),
        // 💧 Generic routes generator.
        .package(url: "https://github.com/VaporMicroService/Avenue.git", from: "0.0.3"),
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostGIS", "Vapor", "Avenue"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

