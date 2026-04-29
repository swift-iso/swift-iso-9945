// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Tests use Apple native Testing framework
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
import Error_Primitives

@testable import ISO_9945_Kernel

extension Kernel.Socket.Backlog {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Socket.Backlog.Test.Unit {
    @Test
    func `Backlog type exists`() {
        let _: Kernel.Socket.Backlog.Type = Kernel.Socket.Backlog.self
    }

    @Test
    func `Backlog from rawValue`() {
        let backlog = Kernel.Socket.Backlog(rawValue: 64)
        #expect(backlog.rawValue == 64)
    }

    @Test
    func `Backlog from Int32`() {
        let backlog = Kernel.Socket.Backlog(256)
        #expect(backlog.rawValue == 256)
    }
}

// MARK: - Constants Tests

extension Kernel.Socket.Backlog.Test.Unit {
    @Test
    func `Backlog.default is 128`() {
        #expect(Kernel.Socket.Backlog.default.rawValue == 128)
    }

    @Test
    func `Backlog.small is 16`() {
        #expect(Kernel.Socket.Backlog.small.rawValue == 16)
    }

    @Test
    func `Backlog.large is 4096`() {
        #expect(Kernel.Socket.Backlog.large.rawValue == 4096)
    }

        @Test
        func `Backlog.max uses SOMAXCONN`() {
            let max = Kernel.Socket.Backlog.max
            #expect(max.rawValue > 0)
        }
}

// MARK: - ExpressibleByIntegerLiteral Tests

extension Kernel.Socket.Backlog.Test.Unit {
    @Test
    func `Backlog from integer literal`() {
        let backlog: Kernel.Socket.Backlog = 512
        #expect(backlog.rawValue == 512)
    }
}

// MARK: - Conformance Tests

extension Kernel.Socket.Backlog.Test.Unit {
    @Test
    func `Backlog is Sendable`() {
        let value: any Sendable = Kernel.Socket.Backlog.default
        #expect(value is Kernel.Socket.Backlog)
    }

    @Test
    func `Backlog is Equatable`() {
        let a = Kernel.Socket.Backlog(128)
        let b = Kernel.Socket.Backlog(128)
        let c = Kernel.Socket.Backlog(256)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Backlog is Hashable`() {
        var set = Set<Kernel.Socket.Backlog>()
        set.insert(.default)
        set.insert(.small)
        set.insert(.default)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - CustomStringConvertible Tests

extension Kernel.Socket.Backlog.Test.Unit {
    @Test
    func `Backlog description shows raw value`() {
        let backlog = Kernel.Socket.Backlog(100)
        #expect(backlog.description == "100")
    }
}

// MARK: - Edge Cases

extension Kernel.Socket.Backlog.Test.EdgeCase {
    @Test
    func `Backlog zero`() {
        let backlog = Kernel.Socket.Backlog(0)
        #expect(backlog.rawValue == 0)
    }

    @Test
    func `Backlog negative`() {
        let backlog = Kernel.Socket.Backlog(-1)
        #expect(backlog.rawValue == -1)
    }

    @Test
    func `Backlog rawValue roundtrip`() {
        for value: Int32 in [0, 1, 16, 128, 4096, Int32.max] {
            let backlog = Kernel.Socket.Backlog(rawValue: value)
            #expect(backlog.rawValue == value)
        }
    }
}
