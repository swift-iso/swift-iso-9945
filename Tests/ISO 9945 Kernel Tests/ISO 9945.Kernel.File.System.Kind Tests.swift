// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Tests use Apple native Testing framework
import Testing


extension Kernel.File.System.Kind {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.System.Kind.Test.Unit {
    @Test
    func `Kind from rawValue`() {
        let kind = Kernel.File.System.Kind(rawValue: 0x1234)
        #expect(kind.rawValue == 0x1234)
    }

    @Test
    func `Kind from UInt64`() {
        let kind = Kernel.File.System.Kind(0xABCD)
        #expect(kind.rawValue == 0xABCD)
    }

    @Test
    func `rawValue roundtrip`() {
        let original: UInt64 = 0x9123_683E
        let kind = Kernel.File.System.Kind(rawValue: original)
        #expect(kind.rawValue == original)
    }
}

// MARK: - Conformance Tests

extension Kernel.File.System.Kind.Test.Unit {
    @Test
    func `Kind is Sendable`() {
        let kind: any Sendable = Kernel.File.System.Kind(0x1234)
        #expect(kind is Kernel.File.System.Kind)
    }

    @Test
    func `Kind is Equatable`() {
        let a = Kernel.File.System.Kind(0x1234)
        let b = Kernel.File.System.Kind(0x1234)
        let c = Kernel.File.System.Kind(0x5678)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Kind is Hashable`() {
        var set = Set<Kernel.File.System.Kind>()
        set.insert(Kernel.File.System.Kind(0x1234))
        set.insert(Kernel.File.System.Kind(0x5678))
        set.insert(Kernel.File.System.Kind(0x1234))  // duplicate
        #expect(set.count == 2)
    }

    @Test
    func `Kind is RawRepresentable`() {
        let kind = Kernel.File.System.Kind(rawValue: 0x1234)
        let fromRaw = Kernel.File.System.Kind(rawValue: kind.rawValue)
        #expect(kind == fromRaw)
    }

    @Test
    func `Kind is CustomStringConvertible`() {
        let kind: any CustomStringConvertible = Kernel.File.System.Kind(0x1234)
        #expect(!kind.description.isEmpty)
    }
}

// MARK: - Linux-specific Tests

#if os(Linux)
    extension Kernel.File.System.Kind.Test.Unit {
        @Test
        func `ext4 constant exists`() {
            let kind = Kernel.File.System.Kind.ext4
            #expect(kind.rawValue == 0xEF53)
        }

        @Test
        func `btrfs constant exists`() {
            let kind = Kernel.File.System.Kind.btrfs
            #expect(kind.rawValue == 0x9123_683E)
        }

        @Test
        func `xfs constant exists`() {
            let kind = Kernel.File.System.Kind.xfs
            #expect(kind.rawValue == 0x5846_5342)
        }

        @Test
        func `tmpfs constant exists`() {
            let kind = Kernel.File.System.Kind.tmpfs
            #expect(kind.rawValue == 0x0102_1994)
        }

        @Test
        func `proc constant exists`() {
            let kind = Kernel.File.System.Kind.proc
            #expect(kind.rawValue == 0x9FA0)
        }

        @Test
        func `sysfs constant exists`() {
            let kind = Kernel.File.System.Kind.sysfs
            #expect(kind.rawValue == 0x6265_6572)
        }

        @Test
        func `nfs constant exists`() {
            let kind = Kernel.File.System.Kind.nfs
            #expect(kind.rawValue == 0x6969)
        }

        @Test
        func `cifs constant exists`() {
            let kind = Kernel.File.System.Kind.cifs
            #expect(kind.rawValue == 0xFF53_4D42)
        }

        @Test
        func `known filesystems have descriptive names`() {
            #expect(Kernel.File.System.Kind.ext4.description == "ext4")
            #expect(Kernel.File.System.Kind.btrfs.description == "btrfs")
            #expect(Kernel.File.System.Kind.xfs.description == "xfs")
            #expect(Kernel.File.System.Kind.tmpfs.description == "tmpfs")
        }
    }

// MARK: - Edge Cases

extension Kernel.File.System.Kind.Test.EdgeCase {
    @Test
    func `zero raw value`() {
        let kind = Kernel.File.System.Kind(0)
        #expect(kind.rawValue == 0)
    }

    @Test
    func `maximum raw value`() {
        let kind = Kernel.File.System.Kind(UInt64.max)
        #expect(kind.rawValue == UInt64.max)
    }

    @Test
    func `different raw values are distinct`() {
        let kind1 = Kernel.File.System.Kind(0x1234)
        let kind2 = Kernel.File.System.Kind(0x5678)
        #expect(kind1 != kind2)
    }
}

#endif
