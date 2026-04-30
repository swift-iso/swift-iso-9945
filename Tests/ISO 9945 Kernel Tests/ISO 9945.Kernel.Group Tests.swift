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
import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import Kernel_File_Primitives
import Path_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension Kernel.Group {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Group.Test.Unit {
    @Test
    func `Group namespace exists`() {
        _ = Kernel.Group.self
    }

    @Test
    func `Group is an enum`() {
        let _: Kernel.Group.Type = Kernel.Group.self
    }

    @Test
    func `Group.ID type exists`() {
        let _: Kernel.Group.ID.Type = Kernel.Group.ID.self
    }
}

// MARK: - Group.ID Tests

extension Kernel.Group.Test.Unit {
    @Test
    func `Group.ID from literal`() {
        let gid: Kernel.Group.ID = 100
        #expect(gid == 100)
    }

    @Test
    func `Group.ID root constant`() {
        let root = Kernel.Group.ID.root
        #expect(root == 0)
    }
}

// MARK: - Group.ID Conformance Tests

extension Kernel.Group.Test.Unit {
    @Test
    func `Group.ID is Sendable`() {
        let value: any Sendable = Kernel.Group.ID.root
        #expect(value is Kernel.Group.ID)
    }

    @Test
    func `Group.ID is Equatable`() {
        let a: Kernel.Group.ID = 100
        let b: Kernel.Group.ID = 100
        let c: Kernel.Group.ID = 200
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Group.ID is Hashable`() {
        let g1: Kernel.Group.ID = 1
        let g2: Kernel.Group.ID = 2
        var set = Set<Kernel.Group.ID>()
        set.insert(g1)
        set.insert(g2)
        set.insert(g1)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.Group.Test.EdgeCase {
    @Test
    func `Group.ID zero is root`() {
        let gid: Kernel.Group.ID = 0
        #expect(gid == .root)
    }

    @Test
    func `Group.ID rawValue roundtrip`() {
        for value: UInt32 in [0, 1, 100, 1000, UInt32.max] {
            let gid = Kernel.Group.ID(__unchecked: (), value)
            #expect(gid.rawValue == value)
        }
    }
}
