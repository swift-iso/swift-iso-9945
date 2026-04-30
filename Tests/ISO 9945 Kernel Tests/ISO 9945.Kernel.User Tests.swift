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
import Kernel_Primitives_Core
import Kernel_Event_Primitives
import Kernel_File_Primitives
import Path_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension Kernel.User {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.User.Test.Unit {
    @Test
    func `User namespace exists`() {
        _ = Kernel.User.self
    }

    @Test
    func `User is an enum`() {
        let _: Kernel.User.Type = Kernel.User.self
    }

    @Test
    func `User.ID type exists`() {
        let _: Kernel.User.ID.Type = Kernel.User.ID.self
    }
}

// MARK: - User.ID Tests

extension Kernel.User.Test.Unit {
    @Test
    func `User.ID from UInt32`() {
        let uid: Kernel.User.ID = 501
        #expect(uid == 501)
    }

    @Test
    func `User.ID root constant`() {
        let root = Kernel.User.ID.root
        #expect(root == 0)
    }
}

// MARK: - User.ID Conformance Tests

extension Kernel.User.Test.Unit {
    @Test
    func `User.ID is Sendable`() {
        let value: any Sendable = Kernel.User.ID.root
        #expect(value is Kernel.User.ID)
    }

    @Test
    func `User.ID is Equatable`() {
        let a: Kernel.User.ID = 501
        let b: Kernel.User.ID = 501
        let c: Kernel.User.ID = 502
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `User.ID is Hashable`() {
        let id501: Kernel.User.ID = 501
        let id502: Kernel.User.ID = 502
        var set = Set<Kernel.User.ID>()
        set.insert(id501)
        set.insert(id502)
        set.insert(id501)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.User.Test.EdgeCase {
    @Test
    func `User.ID zero is root`() {
        let uid: Kernel.User.ID = 0
        #expect(uid == .root)
    }

    @Test
    func `User.ID rawValue roundtrip`() {
        for value: UInt32 in [0, 1, 501, 65534, UInt32.max] {
            let uid = Kernel.User.ID(__unchecked: (), value)
            #expect(uid.rawValue == value)
        }
    }
}
