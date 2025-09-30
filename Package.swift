// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CoffeeApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "CoffeeApp",
            targets: ["CoffeeApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0")
    ],
    targets: [
        .target(
            name: "CoffeeApp",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk")
            ]),
        .testTarget(
            name: "CoffeeAppTests",
            dependencies: ["CoffeeApp"]),
    ]
) 