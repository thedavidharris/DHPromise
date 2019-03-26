// swift-tools-version:4.2
import PackageDescription

let pkg = Package(
    name: "Futura.swift",
    products: [
        .library(name: "Futura", targets: ["Futura"]),
    ],
    targets: [
        .target(name: "Futura", path: "Sources"),
        .testTarget(name: "FuturaTests", dependencies: ["Futura"], path: "Tests")
    ]
)