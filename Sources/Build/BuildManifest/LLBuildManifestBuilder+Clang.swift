//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2015-2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import struct LLBuildManifest.Node
import struct Basics.AbsolutePath
import struct Basics.InternalError
import class Basics.ObservabilityScope
import struct PackageGraph.ResolvedModule
import PackageModel

extension LLBuildManifestBuilder {
    /// Create a llbuild target for a Clang target description and returns the Clang target's outputs.
    @discardableResult
    func createClangCompileCommand(
        _ target: ClangTargetBuildDescription,
        addTargetCmd: Bool = true,
        inputs: [Node] = [],
        createResourceBundle: Bool = true
    ) throws -> [Node] {
        var inputs: [Node] = inputs

        if createResourceBundle {
            // Add resources node as the input to the target. This isn't great because we
            // don't need to block building of a module until its resources are assembled but
            // we don't currently have a good way to express that resources should be built
            // whenever a module is being built.
            if let resourcesNode = try self.createResourcesBundle(for: .clang(target)) {
                inputs.append(resourcesNode)
            }
        }

        func addStaticTargetInputs(_ target: ResolvedModule) {
            if case .swift(let desc)? = self.plan.targetMap[target.id], target.type == .library {
                inputs.append(file: desc.moduleOutputPath)
            } else if case .mixed(let desc)? = plan.targetMap[target.id], target.type == .library {
                inputs.append(file: desc.swiftTargetBuildDescription.moduleOutputPath)
            }
        }

        for dependency in target.target.dependencies(satisfying: target.buildEnvironment) {
            switch dependency {
            case .target(let target, _):
                addStaticTargetInputs(target)

            case .product(let product, _):
                switch product.type {
                case .executable, .snippet, .library(.dynamic), .macro:
                    guard let planProduct = plan.productMap[product.id] else {
                        throw InternalError("unknown product \(product)")
                    }
                    // Establish a dependency on binary of the product.
                    let binary = try planProduct.binaryPath
                    inputs.append(file: binary)

                case .library(.automatic), .library(.static), .plugin:
                    for target in product.targets {
                        addStaticTargetInputs(target)
                    }
                case .test:
                    break
                }
            }
        }

        for binaryPath in target.libraryBinaryPaths {
            let path = target.buildParameters.destinationPath(forBinaryAt: binaryPath)
            if self.fileSystem.isDirectory(binaryPath) {
                inputs.append(directory: path)
            } else {
                inputs.append(file: path)
            }
        }

        var objectFileNodes: [Node] = []

        for path in try target.compilePaths() {
            let args = try target.emitCommandLine(for: path.source)

            let objectFileNode: Node = .file(path.object)
            objectFileNodes.append(objectFileNode)

            self.manifest.addClangCmd(
                name: path.object.pathString,
                description: "Compiling \(target.target.name) \(path.filename)",
                inputs: inputs + [.file(path.source)],
                outputs: [objectFileNode],
                arguments: args,
                dependencies: path.deps.pathString
            )
        }

        let additionalInputs = try addBuildToolPlugins(.clang(target))

        if addTargetCmd {
            self.addTargetCmd(
                target: .clang(target),
                isTestTarget: target.isTestTarget,
                inputs: objectFileNodes + additionalInputs
            )
        }

        return objectFileNodes
    }

    /// Create a llbuild target for a Clang target preparation
    func createClangPrepareCommand(
        _ target: ClangTargetBuildDescription
    ) throws {
        // Create the node for the target so you can --target it.
        // It is a no-op for index preparation.
        let targetName = target.llbuildTargetName
        let output: Node = .virtual(targetName)
        self.manifest.addNode(output, toTarget: targetName)
    }
}
