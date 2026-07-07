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

import ISO_9945_Kernel
import Tagged_Primitives_Standard_Library_Integration
// Tests use Apple native Testing framework
import Testing

extension ISO_9945.Kernel.Inode {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Inode.Test.Unit {
    @Test
    func `Inode type exists`() {
        let _: ISO_9945.Kernel.Inode.Type = ISO_9945.Kernel.Inode.self
    }

    @Test
    func `Inode from rawValue`() {
        let inode = ISO_9945.Kernel.Inode(rawValue: 12345)
        #expect(inode.rawValue == 12345)
    }

    @Test
    func `Inode from UInt64`() {
        let inode = ISO_9945.Kernel.Inode(67890)
        #expect(inode.rawValue == 67890)
    }
}

// MARK: - ExpressibleByIntegerLiteral Tests

extension ISO_9945.Kernel.Inode.Test.Unit {
    @Test
    func `Inode from integer literal`() {
        let inode: ISO_9945.Kernel.Inode = 42
        #expect(inode.rawValue == 42)
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.Inode.Test.Unit {
    @Test
    func `Inode is Sendable`() {
        let value: any Sendable = ISO_9945.Kernel.Inode(0)
        #expect(value is ISO_9945.Kernel.Inode)
    }

    @Test
    func `Inode is Equatable`() {
        let a = ISO_9945.Kernel.Inode(100)
        let b = ISO_9945.Kernel.Inode(100)
        let c = ISO_9945.Kernel.Inode(200)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Inode is Hashable`() {
        var set = Set<ISO_9945.Kernel.Inode>()
        set.insert(ISO_9945.Kernel.Inode(1))
        set.insert(ISO_9945.Kernel.Inode(2))
        set.insert(ISO_9945.Kernel.Inode(1))  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - CustomStringConvertible Tests

extension ISO_9945.Kernel.Inode.Test.Unit {
    @Test
    func `Inode description shows raw value`() {
        let inode = ISO_9945.Kernel.Inode(12345)
        #expect(inode.description == "12345")
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.Inode.Test.EdgeCase {
    @Test
    func `Inode zero`() {
        let inode = ISO_9945.Kernel.Inode(0)
        #expect(inode.rawValue == 0)
    }

    @Test
    func `Inode max value`() {
        let inode = ISO_9945.Kernel.Inode(UInt64.max)
        #expect(inode.rawValue == UInt64.max)
    }

    @Test
    func `Inode rawValue roundtrip`() {
        for value: UInt64 in [0, 1, 100, 12_345_678, UInt64.max] {
            let inode = ISO_9945.Kernel.Inode(rawValue: value)
            #expect(inode.rawValue == value)
        }
    }
}
