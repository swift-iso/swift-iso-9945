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


extension Kernel.Inode {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Inode.Test.Unit {
    @Test
    func `Inode type exists`() {
        let _: Kernel.Inode.Type = Kernel.Inode.self
    }

    @Test
    func `Inode from rawValue`() {
        let inode = Kernel.Inode(rawValue: 12345)
        #expect(inode.rawValue == 12345)
    }

    @Test
    func `Inode from UInt64`() {
        let inode = Kernel.Inode(67890)
        #expect(inode.rawValue == 67890)
    }
}

// MARK: - ExpressibleByIntegerLiteral Tests

extension Kernel.Inode.Test.Unit {
    @Test
    func `Inode from integer literal`() {
        let inode: Kernel.Inode = 42
        #expect(inode.rawValue == 42)
    }
}

// MARK: - Conformance Tests

extension Kernel.Inode.Test.Unit {
    @Test
    func `Inode is Sendable`() {
        let value: any Sendable = Kernel.Inode(0)
        #expect(value is Kernel.Inode)
    }

    @Test
    func `Inode is Equatable`() {
        let a = Kernel.Inode(100)
        let b = Kernel.Inode(100)
        let c = Kernel.Inode(200)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Inode is Hashable`() {
        var set = Set<Kernel.Inode>()
        set.insert(Kernel.Inode(1))
        set.insert(Kernel.Inode(2))
        set.insert(Kernel.Inode(1))  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - CustomStringConvertible Tests

extension Kernel.Inode.Test.Unit {
    @Test
    func `Inode description shows raw value`() {
        let inode = Kernel.Inode(12345)
        #expect(inode.description == "12345")
    }
}

// MARK: - Edge Cases

extension Kernel.Inode.Test.EdgeCase {
    @Test
    func `Inode zero`() {
        let inode = Kernel.Inode(0)
        #expect(inode.rawValue == 0)
    }

    @Test
    func `Inode max value`() {
        let inode = Kernel.Inode(UInt64.max)
        #expect(inode.rawValue == UInt64.max)
    }

    @Test
    func `Inode rawValue roundtrip`() {
        for value: UInt64 in [0, 1, 100, 12_345_678, UInt64.max] {
            let inode = Kernel.Inode(rawValue: value)
            #expect(inode.rawValue == value)
        }
    }
}
