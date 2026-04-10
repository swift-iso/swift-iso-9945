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
import Kernel_Descriptor_Primitives
import Kernel_Event_Primitives
import Kernel_IO_Primitives
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Kernel_Error_Primitives

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
    @Test("User namespace exists")
    func namespaceExists() {
        _ = Kernel.User.self
    }

    @Test("User is an enum")
    func isEnum() {
        let _: Kernel.User.Type = Kernel.User.self
    }

    @Test("User.ID type exists")
    func idTypeExists() {
        let _: Kernel.User.ID.Type = Kernel.User.ID.self
    }
}

// MARK: - User.ID Tests

extension Kernel.User.Test.Unit {
    @Test("User.ID from UInt32")
    func idFromUInt32() {
        let uid: Kernel.User.ID = 501
        #expect(uid == 501)
    }

    @Test("User.ID root constant")
    func rootConstant() {
        let root = Kernel.User.ID.root
        #expect(root == 0)
    }
}

// MARK: - User.ID Conformance Tests

extension Kernel.User.Test.Unit {
    @Test("User.ID is Sendable")
    func idIsSendable() {
        let value: any Sendable = Kernel.User.ID.root
        #expect(value is Kernel.User.ID)
    }

    @Test("User.ID is Equatable")
    func idIsEquatable() {
        let a: Kernel.User.ID = 501
        let b: Kernel.User.ID = 501
        let c: Kernel.User.ID = 502
        #expect(a == b)
        #expect(a != c)
    }

    @Test("User.ID is Hashable")
    func idIsHashable() {
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
    @Test("User.ID zero is root")
    func zeroIsRoot() {
        let uid: Kernel.User.ID = 0
        #expect(uid == .root)
    }

    @Test("User.ID rawValue roundtrip")
    func rawValueRoundtrip() {
        for value: UInt32 in [0, 1, 501, 65534, UInt32.max] {
            let uid = Kernel.User.ID(__unchecked: (), value)
            #expect(uid.rawValue == value)
        }
    }
}
