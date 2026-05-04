// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Testing
import Tagged_Primitives_Standard_Library_Integration
import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import Path_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Group {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Group.Test.Unit {
    @Test
    func `Group namespace exists`() {
        _ = ISO_9945.Kernel.Group.self
    }

    @Test
    func `Group is an enum`() {
        let _: ISO_9945.Kernel.Group.Type = ISO_9945.Kernel.Group.self
    }

    @Test
    func `Group.ID type exists`() {
        let _: ISO_9945.Kernel.Group.ID.Type = ISO_9945.Kernel.Group.ID.self
    }
}

// MARK: - Group.ID Tests

extension ISO_9945.Kernel.Group.Test.Unit {
    @Test
    func `Group.ID from literal`() {
        let gid: ISO_9945.Kernel.Group.ID = 100
        #expect(gid == 100)
    }

    @Test
    func `Group.ID root constant`() {
        let root = ISO_9945.Kernel.Group.ID.root
        #expect(root == 0)
    }
}

// MARK: - Group.ID Conformance Tests

extension ISO_9945.Kernel.Group.Test.Unit {
    @Test
    func `Group.ID is Sendable`() {
        let value: any Sendable = ISO_9945.Kernel.Group.ID.root
        #expect(value is ISO_9945.Kernel.Group.ID)
    }

    @Test
    func `Group.ID is Equatable`() {
        let a: ISO_9945.Kernel.Group.ID = 100
        let b: ISO_9945.Kernel.Group.ID = 100
        let c: ISO_9945.Kernel.Group.ID = 200
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Group.ID is Hashable`() {
        let g1: ISO_9945.Kernel.Group.ID = 1
        let g2: ISO_9945.Kernel.Group.ID = 2
        var set = Set<ISO_9945.Kernel.Group.ID>()
        set.insert(g1)
        set.insert(g2)
        set.insert(g1)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.Group.Test.EdgeCase {
    @Test
    func `Group.ID zero is root`() {
        let gid: ISO_9945.Kernel.Group.ID = 0
        #expect(gid == .root)
    }

    @Test
    func `Group.ID rawValue roundtrip`() {
        for value: UInt32 in [0, 1, 100, 1000, UInt32.max] {
            let gid = ISO_9945.Kernel.Group.ID(_unchecked: value)
            #expect(gid.underlying == value)
        }
    }
}
