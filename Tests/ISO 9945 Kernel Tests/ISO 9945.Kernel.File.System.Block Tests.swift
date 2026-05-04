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
import Tagged_Primitives_Standard_Library_Integration
import ISO_9945_Kernel
import ISO_9945_Kernel_Test_Support


extension ISO_9945.Kernel.File.System.Block {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.System.Block.Test.Unit {
    @Test
    func `Block namespace exists`() {
        _ = ISO_9945.Kernel.File.System.Block.self
    }

    @Test
    func `Block is an enum`() {
        let _: ISO_9945.Kernel.File.System.Block.Type = ISO_9945.Kernel.File.System.Block.self
    }
}

// MARK: - Nested Types

extension ISO_9945.Kernel.File.System.Block.Test.Unit {
    @Test
    func `Block.Size type exists`() {
        let _: ISO_9945.Kernel.File.System.Block.Size.Type = ISO_9945.Kernel.File.System.Block.Size.self
    }

    @Test
    func `Block.Count type exists`() {
        let _: ISO_9945.Kernel.File.System.Block.Count.Type = ISO_9945.Kernel.File.System.Block.Count.self
    }
}

// MARK: - Size Tests

extension ISO_9945.Kernel.File.System.Block.Test.Unit {
    @Test
    func `Size from UInt64`() {
        let size = ISO_9945.Kernel.File.System.Block.Size(512)
        #expect(size == 512)
    }

    @Test
    func `Size sector512 constant`() {
        let size = ISO_9945.Kernel.File.System.Block.Size.sector512
        #expect(size == 512)
    }

    @Test
    func `Size page4096 constant`() {
        let size = ISO_9945.Kernel.File.System.Block.Size.page4096
        #expect(size == 4096)
    }

    @Test
    func `Size is Comparable`() {
        let small = ISO_9945.Kernel.File.System.Block.Size(512)
        let large = ISO_9945.Kernel.File.System.Block.Size(4096)
        #expect(small < large)
        #expect(large > small)
    }

    @Test
    func `Size is ExpressibleByIntegerLiteral`() {
        let size: ISO_9945.Kernel.File.System.Block.Size = 8192
        #expect(size == 8192)
    }

    @Test
    func `Size is Sendable`() {
        let size: any Sendable = ISO_9945.Kernel.File.System.Block.Size(4096)
        #expect(size is ISO_9945.Kernel.File.System.Block.Size)
    }

    @Test
    func `Size is Equatable`() {
        let a = ISO_9945.Kernel.File.System.Block.Size(4096)
        let b = ISO_9945.Kernel.File.System.Block.Size(4096)
        let c = ISO_9945.Kernel.File.System.Block.Size(512)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Size is Hashable`() {
        var set = Set<ISO_9945.Kernel.File.System.Block.Size>()
        set.insert(ISO_9945.Kernel.File.System.Block.Size(512))
        set.insert(ISO_9945.Kernel.File.System.Block.Size(4096))
        set.insert(ISO_9945.Kernel.File.System.Block.Size(512))  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Count Tests

extension ISO_9945.Kernel.File.System.Block.Test.Unit {
    @Test
    func `Count zero constant`() {
        let count = ISO_9945.Kernel.File.System.Block.Count.zero
        #expect(count == .zero)
    }

    @Test
    func `Count addition`() {
        let a = ISO_9945.Kernel.File.System.Block.Count(UInt(100))
        let b = ISO_9945.Kernel.File.System.Block.Count(UInt(50))
        let sum = a + b
        #expect(sum == ISO_9945.Kernel.File.System.Block.Count(UInt(150)))
    }

    @Test
    func `Count subtraction (saturating)`() {
        let a = ISO_9945.Kernel.File.System.Block.Count(UInt(100))
        let b = ISO_9945.Kernel.File.System.Block.Count(UInt(30))
        let diff = a.subtract.saturating(b)
        #expect(diff == ISO_9945.Kernel.File.System.Block.Count(UInt(70)))
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.System.Block.Test.EdgeCase {
    @Test
    func `Size zero value`() {
        let size = ISO_9945.Kernel.File.System.Block.Size(0)
        #expect(size == 0)
    }

    @Test
    func `Size maximum value`() {
        let size = ISO_9945.Kernel.File.System.Block.Size(UInt64.max)
        #expect(size.rawValue == UInt64.max)
    }

    @Test
    func `Count zero additions`() {
        let zero = ISO_9945.Kernel.File.System.Block.Count.zero
        let hundred = ISO_9945.Kernel.File.System.Block.Count(UInt(100))
        #expect((zero + hundred) == hundred)
        #expect((hundred + zero) == hundred)
    }

    @Test
    func `Size ordering consistency`() {
        let sizes = [
            ISO_9945.Kernel.File.System.Block.Size(512),
            ISO_9945.Kernel.File.System.Block.Size(1024),
            ISO_9945.Kernel.File.System.Block.Size(2048),
            ISO_9945.Kernel.File.System.Block.Size(4096),
        ]

        for i in 0..<(sizes.count - 1) {
            #expect(sizes[i] < sizes[i + 1])
        }
    }
}
