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
        // 🔵 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        // 💧 Generic routes generator.
        .package(url: "https://github.com/VaporMicroService/Avenue.git", from: "0.0.1"),
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "Avenue"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

