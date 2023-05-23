// swift-tools-version: 999.0
// FIXME(ncooke3): Update above version with the next version of SwiftPM.

import PackageDescription

let package = Package(
    name: "MixedTargets",
    products: [
        .library(
            name: "BasicMixedTarget",
            targets: ["BasicMixedTarget"]
        ),
        .library(
            name: "StaticallyLinkedBasicMixedTarget",
            type: .static,
            targets: ["BasicMixedTarget"]
        ),
        .library(
            name: "DynamicallyLinkedBasicMixedTarget",
            type: .dynamic,
            targets: ["BasicMixedTarget"]
        )
    ],
    dependencies: [],
    targets: [
        // MARK: - BasicMixedTarget
        .target(
            name: "BasicMixedTarget"
        ),
        .testTarget(
            name: "BasicMixedTargetTests",
            dependencies: ["BasicMixedTarget"]
        ),

        // MARK: - BasicMixedTargetWithManualBridgingHeader
        .target(
            name: "BasicMixedTargetWithManualBridgingHeader"
        ),
        .testTarget(
            name: "BasicMixedTargetWithManualBridgingHeaderTests",
            dependencies: ["BasicMixedTargetWithManualBridgingHeader"]
        ),

        // MARK: - BasicMixedTargetWithUmbrellaHeader
        .target(
            name: "BasicMixedTargetWithUmbrellaHeader"
        ),
        .testTarget(
            name: "BasicMixedTargetWithUmbrellaHeaderTests",
            dependencies: ["BasicMixedTargetWithUmbrellaHeader"]
        ),

        // MARK: - MixedTargetWithResources
        .target(
            name: "MixedTargetWithResources",
            resources: [
                .process("foo.txt")
            ]
        ),
        .testTarget(
            name: "MixedTargetWithResourcesTests",
            dependencies: ["MixedTargetWithResources"]
        ),

        // MARK: - MixedTargetWithCustomModuleMap
        .target(
            name: "MixedTargetWithCustomModuleMap"
        ),
        .testTarget(
            name: "MixedTargetWithCustomModuleMapTests",
            dependencies: ["MixedTargetWithCustomModuleMap"]
        ), 

        // MARK: - MixedTargetWithInvalidCustomModuleMap
        .target(
            name: "MixedTargetWithInvalidCustomModuleMap"
        ),

        // MARK: - MixedTargetWithCustomModuleMapAndResources
        .target(
            name: "MixedTargetWithCustomModuleMapAndResources",
            resources: [
                .process("foo.txt")
            ]
        ),
        .testTarget(
            name: "MixedTargetWithCustomModuleMapAndResourcesTests",
            dependencies: ["MixedTargetWithCustomModuleMapAndResources"]
        ),  

        // MARK: - MixedTargetWithC++
        .target(
            name: "MixedTargetWithCXX"
        ),
        .testTarget(
            name: "MixedTargetWithCXXTests",
            dependencies: ["MixedTargetWithCXX"]
        ),

        // MARK: - MixedTargetWithCXXAndCustomModuleMap
        .target(
            name: "MixedTargetWithCXXAndCustomModuleMap"
        ),

        // MARK: - MixedTargetWithPublicCXXAPI 
        // In order to import this target into downstream targets, two
        // additional things must be done (depending on whether the target is
        // being imported into a Clang vs. Swift context):
        // - Clang context: If the client wants to import the module, client
        //   must pass `-fcxx-modules` and `-fmodules` as unsafe flags in
        //   the target's `cSettings`. Else, the client can just import
        //   individual public headers without further configuring the target.
        // - Swift context: The mixed target needs to make a custom module
        //   map that only exposes public CXX headers in a non-Swift context.
        //   
        //      // module.modulemap
        //      module MixedTargetWithPublicCXXAPI {
        //          umbrella header "PublicNonCXXHeaders.h"
        //          
        //          module CXX {
        //              header "PublicCXXHeaders.h"
        //              export *
        //              requires !swift
        //          }
        //          
        //          export *
        //      }
        //
        .target(
            name: "MixedTargetWithPublicCXXAPI"
        ),
        .testTarget(
            name: "MixedTargetWithPublicCXXAPITests",
            dependencies: ["MixedTargetWithPublicCXXAPI"],
            cSettings: [
                // To get the `MixedTargetWithPublicCXXAPI` target to build for use in
                // an Objective-C context (e.g. Objective-C++ test file), the following 
                // unsafe flags must be passed.
                .unsafeFlags(["-fcxx-modules", "-fmodules"])
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
            ]
        ),

        // MARK: - Experimental C++ Support
        // TODO(ncooke3): Decide where to put `-enable-experimental-cxx-interop`
        // within the implementation. Stub it out.

        // First requirements:
        // - Public Swift API
        // - Private Swift API
        // - Public C++ API
        // - Private C++ API
        // Second requirements:
        // - Public Swift API
        // - Private Swift API
        // - Public C++ API
        // - Private C++ API
        .target(
            name: "MixedTargetWithExperimentalCXX",
            // TODO(ncooke3): Auto detect and move within the implementation.
            swiftSettings: [.unsafeFlags(["-I", "Sources/MixedTargetWithExperimentalCXX", "-enable-experimental-cxx-interop"])]
        ),

        .target(
            name: "SwiftTargetDependsOnMixedTargetWithCXX",
            dependencies: ["MixedTargetWithExperimentalCXX"],
            // TODO(ncooke3): Auto detect and move within the implementation.
            // NOTE(ncooke3): Why do clients ned to pass this flag?
            swiftSettings: [.unsafeFlags(["-enable-experimental-cxx-interop"])]
        ),

//        .target(
//            name: "ClangTargetDependsOnMixedTargetWithCXX",
//            dependencies: ["MixedTargetWithPublicCXXAPI"],
//            swiftSettings: [.unsafeFlags([
//                "-enable-experimental-cxx-interop"
//            ])]
//        ),

        // MARK: - MixedTargetWithC
        .target(
            name: "MixedTargetWithC"
        ),
        .testTarget(
            name: "MixedTargetWithCTests",
            dependencies: ["MixedTargetWithC"]
        ),

        // MARK: - MixedTargetWithNonPublicHeaders
        .target(
            name: "MixedTargetWithNonPublicHeaders"
        ),
        // This test target should fail to build. See
        // `testNonPublicHeadersAreNotVisibleFromOutsideOfTarget`.
        .testTarget(
            name: "MixedTargetWithNonPublicHeadersTests",
            dependencies: ["MixedTargetWithNonPublicHeaders"]
        ),

        // MARK: - MixedTargetWithCustomPaths
        .target(
            name: "MixedTargetWithCustomPaths",
            path: "MixedTargetWithCustomPaths/Sources",
            publicHeadersPath: "Public",
            cSettings: [
                .headerSearchPath("../../")
            ]
        ),

        // MARK: - MixedTargetWithNestedPublicHeaders
        .target(
            name: "MixedTargetWithNestedPublicHeaders",
            publicHeadersPath: "Blah/Public"
        ),

        // MARK: - MixedTargetWithNestedPublicHeadersAndCustomModuleMap
        .target(
            name: "MixedTargetWithNestedPublicHeadersAndCustomModuleMap",
            publicHeadersPath: "Blah/Public"
        ),

        // MARK: - MixedTargetWithNoPublicObjectiveCHeaders
       .target(
           name: "MixedTargetWithNoPublicObjectiveCHeaders"
       ),
        .testTarget(
            name: "MixedTargetWithNoPublicObjectiveCHeadersTests",
            dependencies: ["MixedTargetWithNoPublicObjectiveCHeaders"]
        ),

        // MARK: - MixedTargetWithNoObjectiveCCompatibleSwiftAPI
        .target(
           name: "MixedTargetWithNoObjectiveCCompatibleSwiftAPI"
       ),

        // MARK: - MixedTestTargetWithSharedTestUtilities
        .testTarget(
            name: "MixedTestTargetWithSharedUtilitiesTests"
        ),

        // MARK: - PrivateHeadersCanBeTestedViaHeaderSearchPathsTests
        .testTarget(
            name: "PrivateHeadersCanBeTestedViaHeaderSearchPathsTests",
            dependencies: ["MixedTargetWithNonPublicHeaders"],
            cSettings: [
                // Adding a header search path at the root of the package will
                // enable the Objective-C tests to import private headers.
                .headerSearchPath("../../")
            ]
        ),

        // MARK: - MixedTargetsPublicHeadersAreIncludedInHeaderSearchPathsForObjcSource
        .target(
            name: "MixedTargetsPublicHeadersAreIncludedInHeaderSearchPathsForObjcSource"
        ),

        // MARK: - Targets for testing the integration of a mixed target
        .target(
            name: "ClangTargetDependsOnMixedTarget",
            dependencies: ["BasicMixedTarget"]
         ),
         .target(
             name: "SwiftTargetDependsOnMixedTarget",
             dependencies: ["BasicMixedTarget"]
         ),
         .target(
             name: "MixedTargetDependsOnMixedTarget",
             dependencies: ["BasicMixedTarget"]
         ),
         .target(
             name: "MixedTargetDependsOnClangTarget",
             dependencies: ["ClangTarget"]
         ),
         .target(
             name: "MixedTargetDependsOnSwiftTarget",
             dependencies: ["SwiftTarget"]
         ),
         // The below two targets are used for testing the above targets.
         .target(name: "SwiftTarget"),
         .target(name: "ClangTarget")

    ]
)