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
import ISO_9945
import Kernel_Primitives

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
    @Test("Group namespace exists")
    func namespaceExists() {
        _ = Kernel.Group.self
    }

    @Test("Group is an enum")
    func isEnum() {
        let _: Kernel.Group.Type = Kernel.Group.self
    }

    @Test("Group.ID type exists")
    func idTypeExists() {
        let _: Kernel.Group.ID.Type = Kernel.Group.ID.self
    }
}

// MARK: - Group.ID Tests

extension Kernel.Group.Test.Unit {
    @Test("Group.ID from literal")
    func idFromLiteral() {
        let gid: Kernel.Group.ID = 100
        #expect(gid == 100)
    }

    @Test("Group.ID root constant")
    func rootConstant() {
        let root = Kernel.Group.ID.root
        #expect(root == 0)
    }
}

// MARK: - Group.ID Conformance Tests

extension Kernel.Group.Test.Unit {
    @Test("Group.ID is Sendable")
    func idIsSendable() {
        let value: any Sendable = Kernel.Group.ID.root
        #expect(value is Kernel.Group.ID)
    }

    @Test("Group.ID is Equatable")
    func idIsEquatable() {
        let a: Kernel.Group.ID = 100
        let b: Kernel.Group.ID = 100
        let c: Kernel.Group.ID = 200
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Group.ID is Hashable")
    func idIsHashable() {
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
    @Test("Group.ID zero is root")
    func zeroIsRoot() {
        let gid: Kernel.Group.ID = 0
        #expect(gid == .root)
    }

    @Test("Group.ID rawValue roundtrip")
    func rawValueRoundtrip() {
        for value: UInt32 in [0, 1, 100, 1000, UInt32.max] {
            let gid = Kernel.Group.ID(__unchecked: (), value)
            #expect(gid.rawValue == value)
        }
    }
}
