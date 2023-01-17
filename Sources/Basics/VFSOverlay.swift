//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import class Foundation.JSONEncoder
import struct TSCBasic.AbsolutePath
import protocol TSCBasic.FileSystem

public struct VFSOverlay: Encodable {

    public class Resource: Encodable {
        private let name: String
        private let type: String

        fileprivate init(name: String, type: String) {
            self.name = name
            self.type = type
        }
    }

    public class File: Resource {
        private enum CodingKeys: String, CodingKey {
            case externalContents = "external-contents"
        }

        private let externalContents: String

        public init(name: String, externalContents: String) {
            self.externalContents = externalContents
            super.init(name: name, type: "file")
        }

        public override func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(externalContents, forKey: .externalContents)
            try super.encode(to: encoder)
        }
    }

    public class Directory: Resource {
        private enum CodingKeys: CodingKey {
            case contents
        }

        private let contents: [File]

        public init(name: String, contents: [File]) {
            self.contents = contents
            super.init(name: name, type: "directory")
        }

        public override func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(contents, forKey: .contents)
            try super.encode(to: encoder)
        }
    }

    enum CodingKeys: String, CodingKey {
        case roots
        case useExternalNames = "use-external-names"
        case caseSensitive = "case-sensitive"
        case version
    }

    private let roots: [Resource]
    private let useExternalNames = false
    private let caseSensitive = false
    private let version = 0

    public init(roots: [File]) {
        self.roots = roots
    }

    public func write(to path: AbsolutePath, fileSystem: FileSystem) throws {
        // VFS overlay files are YAML, but ours is simple enough that it works when being written using `JSONEncoder`.
        try JSONEncoder.makeWithDefaults(prettified: false).encode(path: path, fileSystem: fileSystem, self)
    }
}
