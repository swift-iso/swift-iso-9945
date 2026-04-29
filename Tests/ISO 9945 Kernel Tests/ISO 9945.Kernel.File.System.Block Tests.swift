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
import Kernel_Primitives_Test_Support

@testable import Kernel_File_Primitives

extension Kernel.File.System.Block {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.System.Block.Test.Unit {
    @Test
    func `Block namespace exists`() {
        _ = Kernel.File.System.Block.self
    }

    @Test
    func `Block is an enum`() {
        let _: Kernel.File.System.Block.Type = Kernel.File.System.Block.self
    }
}

// MARK: - Nested Types

extension Kernel.File.System.Block.Test.Unit {
    @Test
    func `Block.Size type exists`() {
        let _: Kernel.File.System.Block.Size.Type = Kernel.File.System.Block.Size.self
    }

    @Test
    func `Block.Count type exists`() {
        let _: Kernel.File.System.Block.Count.Type = Kernel.File.System.Block.Count.self
    }
}

// MARK: - Size Tests

extension Kernel.File.System.Block.Test.Unit {
    @Test
    func `Size from UInt64`() {
        let size = Kernel.File.System.Block.Size(512)
        #expect(size == 512)
    }

    @Test
    func `Size sector512 constant`() {
        let size = Kernel.File.System.Block.Size.sector512
        #expect(size == 512)
    }

    @Test
    func `Size page4096 constant`() {
        let size = Kernel.File.System.Block.Size.page4096
        #expect(size == 4096)
    }

    @Test
    func `Size is Comparable`() {
        let small = Kernel.File.System.Block.Size(512)
        let large = Kernel.File.System.Block.Size(4096)
        #expect(small < large)
        #expect(large > small)
    }

    @Test
    func `Size is ExpressibleByIntegerLiteral`() {
        let size: Kernel.File.System.Block.Size = 8192
        #expect(size == 8192)
    }

    @Test
    func `Size is Sendable`() {
        let size: any Sendable = Kernel.File.System.Block.Size(4096)
        #expect(size is Kernel.File.System.Block.Size)
    }

    @Test
    func `Size is Equatable`() {
        let a = Kernel.File.System.Block.Size(4096)
        let b = Kernel.File.System.Block.Size(4096)
        let c = Kernel.File.System.Block.Size(512)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Size is Hashable`() {
        var set = Set<Kernel.File.System.Block.Size>()
        set.insert(Kernel.File.System.Block.Size(512))
        set.insert(Kernel.File.System.Block.Size(4096))
        set.insert(Kernel.File.System.Block.Size(512))  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Count Tests

extension Kernel.File.System.Block.Test.Unit {
    @Test
    func `Count zero constant`() {
        let count = Kernel.File.System.Block.Count.zero
        #expect(count == .zero)
    }

    @Test
    func `Count addition`() {
        let a = Kernel.File.System.Block.Count(UInt(100))
        let b = Kernel.File.System.Block.Count(UInt(50))
        let sum = a + b
        #expect(sum == Kernel.File.System.Block.Count(UInt(150)))
    }

    @Test
    func `Count subtraction (saturating)`() {
        let a = Kernel.File.System.Block.Count(UInt(100))
        let b = Kernel.File.System.Block.Count(UInt(30))
        let diff = a.subtract.saturating(b)
        #expect(diff == Kernel.File.System.Block.Count(UInt(70)))
    }
}

// MARK: - Edge Cases

extension Kernel.File.System.Block.Test.EdgeCase {
    @Test
    func `Size zero value`() {
        let size = Kernel.File.System.Block.Size(0)
        #expect(size == 0)
    }

    @Test
    func `Size maximum value`() {
        let size = Kernel.File.System.Block.Size(UInt64.max)
        #expect(size.rawValue == UInt64.max)
    }

    @Test
    func `Count zero additions`() {
        let zero = Kernel.File.System.Block.Count.zero
        let hundred = Kernel.File.System.Block.Count(UInt(100))
        #expect((zero + hundred) == hundred)
        #expect((hundred + zero) == hundred)
    }

    @Test
    func `Size ordering consistency`() {
        let sizes = [
            Kernel.File.System.Block.Size(512),
            Kernel.File.System.Block.Size(1024),
            Kernel.File.System.Block.Size(2048),
            Kernel.File.System.Block.Size(4096),
        ]

        for i in 0..<(sizes.count - 1) {
            #expect(sizes[i] < sizes[i + 1])
        }
    }
}
