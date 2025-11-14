// swift-tools-version: 5.9
// Guardian One iOS App - Swift Package Dependencies

import PackageDescription

let package = Package(
    name: "GuardianOne",
    platforms: [
        .iOS(.v17),
        .macOS(.v14) // For Mac Catalyst
    ],
    products: [
        .library(
            name: "GuardianOne",
            targets: ["GuardianOne"]
        ),
    ],
    dependencies: [
        // Supabase Swift SDK for authentication and database
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.0.0"),

        // MapKit extensions for aviation
        .package(url: "https://github.com/mapbox/mapbox-maps-ios.git", from: "11.0.0"),

        // OpenAI Swift SDK for AI coaching
        .package(url: "https://github.com/MacPaw/OpenAI.git", from: "0.2.0"),

        // Combine extensions
        .package(url: "https://github.com/CombineCommunity/CombineExt.git", from: "1.0.0"),

        // SwiftUI extensions
        .package(url: "https://github.com/siteline/SwiftUI-Introspect.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "GuardianOne",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "MapboxMaps", package: "mapbox-maps-ios"),
                .product(name: "OpenAI", package: "OpenAI"),
                .product(name: "CombineExt", package: "CombineExt"),
                .product(name: "SwiftUIIntrospect", package: "SwiftUI-Introspect"),
            ]
        ),
        .testTarget(
            name: "GuardianOneTests",
            dependencies: ["GuardianOne"]
        ),
    ]
)

/*
 Dependencies Explained:

 1. Supabase Swift SDK:
    - User authentication (Apple Sign-In integration)
    - Real-time flight log sync across devices
    - PostgreSQL database operations

 2. Mapbox Maps:
    - Moving map display with aviation charts
    - Custom overlays (airspace, weather, traffic)
    - Offline map tile caching

 3. OpenAI Swift SDK:
    - AI coaching API integration
    - GPT-4 Turbo chat completions
    - Streaming responses for real-time coaching

 4. CombineExt:
    - Reactive data streams for GPS updates
    - ADS-B data processing pipelines
    - State management helpers

 5. SwiftUI Introspect:
    - UIKit interoperability (camera access, low-level controls)
    - Custom gesture recognizers
    - Advanced animations

 Installation:
 1. Open Terminal in ios/ directory
 2. Run: swift package resolve
 3. Dependencies will download to .build/ directory

 Xcode Integration:
 1. File → New → Project → iOS App
 2. Add Package Dependencies → Local Path → select ios/Package.swift
 3. Import in Swift files: import Supabase, import MapboxMaps, etc.

 Next Steps (Milestone 2):
 - Pixel agent will create GuardianOne.xcodeproj
 - Implement LocationService.swift (Core Location wrapper)
 - Implement MapView.swift (moving map UI)
 - Implement AuthService.swift (Supabase auth integration)
*/
