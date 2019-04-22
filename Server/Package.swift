// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Server",
    products: [
        .executable(name: "Server", targets: ["Server"])
    ],
    dependencies: [
        .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"), //http 服务器
        .package(url: "https://github.com/PerfectlySoft/Perfect-MySQL.git",from: "3.4.0"), //MySql
        .package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", from: "3.0.0") //Mustache模版语言
    ],
    targets: [
        .target(name: "Server", dependencies: ["PerfectHTTPServer","PerfectMySQL","PerfectMustache"])
    ]
)
