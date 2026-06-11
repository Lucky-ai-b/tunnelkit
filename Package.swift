// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TunnelKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TunnelKit",
            targets: ["TunnelKit"]
        ),
        .library(
            name: "TunnelKitOpenVPN",
            targets: ["TunnelKitOpenVPN"]
        ),
        .library(
            name: "TunnelKitOpenVPNAppExtension",
            targets: ["TunnelKitOpenVPNAppExtension"]
        ),
        .library(
            name: "TunnelKitWireGuard",
            targets: ["TunnelKitWireGuard"]
        ),
        .library(
            name: "TunnelKitWireGuardAppExtension",
            targets: ["TunnelKitWireGuardAppExtension"]
        ),
        .library(
            name: "TunnelKitLZO",
            targets: ["TunnelKitLZO"]
        )
    ],
    dependencies: [
        // Forks pinned to a commit: these forks have no release tags, only `master`.
        .package(url: "https://github.com/Lucky-ai-b/SwiftyBeaver", revision: "0b2a00871a15a80407273412fd39967713ead7d3"),
        .package(url: "https://github.com/Lucky-ai-b/openssl-apple", revision: "685680e3adbfccdeef84d37fc5732b0031f188c7"),
        .package(url: "https://github.com/Lucky-ai-b/wg-go-apple", revision: "dfd5cc1f8840686297a4c3ec3e88b6a1adf87331")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TunnelKit",
            dependencies: [
                "TunnelKitCore",
                "TunnelKitManager"
            ]
        ),
        .target(
            name: "TunnelKitCore",
            dependencies: [
                "__TunnelKitUtils",
                "CTunnelKitCore",
                "SwiftyBeaver"
            ]),
        .target(
            name: "TunnelKitManager",
            dependencies: [
                "SwiftyBeaver"
            ]),
        .target(
            name: "TunnelKitAppExtension",
            dependencies: [
                "TunnelKitCore"
            ]),
        .target(
            name: "TunnelKitOpenVPN",
            dependencies: [
                "TunnelKitOpenVPNCore",
                "TunnelKitOpenVPNManager"
            ]),
        //
        .target(
            name: "TunnelKitOpenVPNCore",
            dependencies: [
                "TunnelKitCore",
                "CTunnelKitOpenVPNCore",
                "CTunnelKitOpenVPNProtocol" // FIXME: remove dependency on TLSBox
            ]),
        .target(
            name: "TunnelKitOpenVPNManager",
            dependencies: [
                "TunnelKitManager",
                "TunnelKitOpenVPNCore"
            ]),
        .target(
            name: "TunnelKitOpenVPNProtocol",
            dependencies: [
                "TunnelKitOpenVPNCore",
                "CTunnelKitOpenVPNProtocol"
            ]),
        .target(
            name: "TunnelKitOpenVPNAppExtension",
            dependencies: [
                "TunnelKitAppExtension",
                "TunnelKitOpenVPNCore",
                "TunnelKitOpenVPNManager",
                "TunnelKitOpenVPNProtocol"
            ]),
        //
        .target(
            name: "TunnelKitWireGuard",
            dependencies: [
                "TunnelKitWireGuardCore",
                "TunnelKitWireGuardManager"
            ]),
        .target(
            name: "TunnelKitWireGuardCore",
            dependencies: [
                "__TunnelKitUtils",
                "TunnelKitCore",
                "WireGuardKit",
                "SwiftyBeaver"
            ]),
        .target(
            name: "TunnelKitWireGuardManager",
            dependencies: [
                "TunnelKitManager",
                "TunnelKitWireGuardCore"
            ]),
        .target(
            name: "TunnelKitWireGuardAppExtension",
            dependencies: [
                "TunnelKitWireGuardCore",
                "TunnelKitWireGuardManager"
            ]),
        .target(
            name: "TunnelKitLZO",
            dependencies: [],
            exclude: [
                "lib/COPYING",
                "lib/Makefile",
                "lib/README.LZO",
                "lib/testmini.c"
            ]),
        //
        .target(
            name: "CTunnelKitCore",
            dependencies: []),
        .target(
            name: "CTunnelKitOpenVPNCore",
            dependencies: []),
        .target(
            name: "CTunnelKitOpenVPNProtocol",
            dependencies: [
                "CTunnelKitCore",
                "CTunnelKitOpenVPNCore",
                "openssl-apple"
            ]),
        .target(
            name: "__TunnelKitUtils",
            dependencies: []),
        //
        // Vendored WireGuardKit (Swift wrapper) backed by the prebuilt
        // wg-go-apple binary instead of building wireguard-go from source.
        .target(
            name: "WireGuardKit",
            dependencies: [
                "WireGuardKitC",
                "WireGuardKitGo"
            ],
            path: "Sources/Sources/WireGuardKit"),
        .target(
            name: "WireGuardKitC",
            dependencies: [],
            path: "Sources/Sources/WireGuardKitC",
            publicHeadersPath: "."),
        .target(
            name: "WireGuardKitGo",
            dependencies: [
                .product(name: "wg-go-apple", package: "wg-go-apple")
            ],
            path: "Sources/Sources/WireGuardKitGo",
            exclude: [
                "go.mod",
                "go.sum",
                "api-apple.go",
                "Makefile"
            ],
            publicHeadersPath: "."),
        //
        .testTarget(
            name: "TunnelKitCoreTests",
            dependencies: [
                "TunnelKitCore"
            ],
            exclude: [
                "RandomTests.swift",
                "RawPerformanceTests.swift",
                "RoutingTests.swift"
            ]),
        .testTarget(
            name: "TunnelKitOpenVPNTests",
            dependencies: [
                "TunnelKitOpenVPNCore",
                "TunnelKitOpenVPNAppExtension",
                "TunnelKitLZO"
            ],
            exclude: [
                "DataPathPerformanceTests.swift",
                "EncryptionPerformanceTests.swift"
            ],
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "TunnelKitLZOTests",
            dependencies: [
                "TunnelKitCore",
                "TunnelKitLZO"
            ])
    ]
)

