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
import Path_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.User {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.User.Test.Unit {
    @Test
    func `User namespace exists`() {
        _ = ISO_9945.Kernel.User.self
    }

    @Test
    func `User is an enum`() {
        let _: ISO_9945.Kernel.User.Type = ISO_9945.Kernel.User.self
    }

    @Test
    func `User.ID type exists`() {
        let _: ISO_9945.Kernel.User.ID.Type = ISO_9945.Kernel.User.ID.self
    }
}

// MARK: - User.ID Tests

extension ISO_9945.Kernel.User.Test.Unit {
    @Test
    func `User.ID from UInt32`() {
        let uid: ISO_9945.Kernel.User.ID = 501
        #expect(uid == 501)
    }

    @Test
    func `User.ID root constant`() {
        let root = ISO_9945.Kernel.User.ID.root
        #expect(root == 0)
    }
}

// MARK: - User.ID Conformance Tests

extension ISO_9945.Kernel.User.Test.Unit {
    @Test
    func `User.ID is Sendable`() {
        let value: any Sendable = ISO_9945.Kernel.User.ID.root
        #expect(value is ISO_9945.Kernel.User.ID)
    }

    @Test
    func `User.ID is Equatable`() {
        let a: ISO_9945.Kernel.User.ID = 501
        let b: ISO_9945.Kernel.User.ID = 501
        let c: ISO_9945.Kernel.User.ID = 502
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `User.ID is Hashable`() {
        let id501: ISO_9945.Kernel.User.ID = 501
        let id502: ISO_9945.Kernel.User.ID = 502
        var set = Set<ISO_9945.Kernel.User.ID>()
        set.insert(id501)
        set.insert(id502)
        set.insert(id501)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.User.Test.EdgeCase {
    @Test
    func `User.ID zero is root`() {
        let uid: ISO_9945.Kernel.User.ID = 0
        #expect(uid == .root)
    }

    @Test
    func `User.ID rawValue roundtrip`() {
        for value: UInt32 in [0, 1, 501, 65534, UInt32.max] {
            let uid = ISO_9945.Kernel.User.ID(__unchecked: (), value)
            #expect(uid.rawValue == value)
        }
    }
}
