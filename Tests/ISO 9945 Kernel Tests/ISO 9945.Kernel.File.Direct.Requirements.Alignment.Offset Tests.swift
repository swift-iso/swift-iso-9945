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
import ISO_9945_Kernel


extension ISO_9945.Kernel.File.Direct.Requirements.Alignment.Offset {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.Direct.Requirements.Alignment.Offset.Test.Unit {
    @Test
    func `Offset type exists`() {
        let _: ISO_9945.Kernel.File.Direct.Requirements.Alignment.Offset.Type =
            ISO_9945.Kernel.File.Direct.Requirements.Alignment.Offset.self
    }

    @Test
    func `isAligned method exists`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let offset = alignment.offset
        _ = offset.isAligned(0)
    }

    @Test
    func `isAligned returns true for aligned offset`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let offset = alignment.offset
        #expect(offset.isAligned(0) == true)
        #expect(offset.isAligned(4096) == true)
        #expect(offset.isAligned(8192) == true)
    }

    @Test
    func `isAligned returns false for unaligned offset`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let offset = alignment.offset
        #expect(offset.isAligned(1) == false)
        #expect(offset.isAligned(100) == false)
        #expect(offset.isAligned(4097) == false)
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.File.Direct.Requirements.Alignment.Offset.Test.Unit {
    @Test
    func `Offset is Sendable`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let offset: any Sendable = alignment.offset
        #expect(offset is ISO_9945.Kernel.File.Direct.Requirements.Alignment.Offset)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.Direct.Requirements.Alignment.Offset.Test.EdgeCase {
    @Test
    func `offset accessor returns consistent value`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let offset1 = alignment.offset
        let offset2 = alignment.offset
        #expect(offset1.isAligned(4096) == offset2.isAligned(4096))
    }

    @Test
    func `zero offset is always aligned`() {
        let alignments: [Memory.Alignment] = [.`512`, .`1024`, .`4096`, .`8192`]
        for value in alignments {
            let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: value)
            #expect(alignment.offset.isAligned(0) == true)
        }
    }
}
