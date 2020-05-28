// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "SwiftServer",
    products: [
        .library(name: "SwiftServer", targets: ["App"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        
        .package(url: "https://github.com/skelpo/APIErrorMiddleware.git",
                 from: "0.1.0"),
        .package(url: "https://github.com/IBM-Swift/Swift-SMTP.git",
                 from: "4.0.1"),
        .package(url: "https://github.com/vapor/fluent-mysql-driver.git",
                 from: "3.0.0"),
        .package(url: "https://github.com/vapor/routing.git",
                 from: "3.0.0"),
        .package(url: "https://github.com/vapor/auth.git",
                 from: "2.0.0"),
        .package(url: "https://github.com/vapor/crypto.git",
                 .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/vapor/http.git",
                 from: "3.0.0"),
        .package(url: "https://github.com/vapor/jwt.git",
                 from: "3.0.0"),
        .package(url: "https://github.com/vapor/console.git",
                 from: "3.0.0"),
        .package(url: "https://github.com/vapor/redis.git",
                 from: "3.0.0-rc"),
        .package(url: "https://github.com/PerfectSideRepos/Perfect-ICONV.git",
                 from:"3.0.1"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git",
                 from: "1.7.1"),
        .package(url: "https://github.com/skelpo/JWTMiddleware.git",
                 from: "0.6.1"),
        .package(url: "https://github.com/vapor/multipart.git",
                 from: "3.0.0"),
        .package(url: "https://github.com/IBM-Swift/LoggerAPI.git",
                 .upToNextMinor(from: "1.8.0")),
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentMySQL",
ㅗ                                            "Routing",
                                            "Authentication",
                                            "Crypto",
                                            "JWTMiddleware",
                                            "Random",
                                            "HTTP",
                                            "JWT",
                                            "Multipart",
                                            "Redis",
                                            "Logging",
                                            "PerfectICONV",
                                            "Vapor",
                                            "APIErrorMiddleware",
                                            "SwiftSMTP",
                                            "SwiftSoup",
                                            "LoggerAPI"
        ]),
        
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

