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


extension ISO_9945.Kernel.File.Direct.Requirements.Alignment.Length {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.Direct.Requirements.Alignment.Length.Test.Unit {
    @Test
    func `Length type exists`() {
        let _: ISO_9945.Kernel.File.Direct.Requirements.Alignment.Length.Type =
            ISO_9945.Kernel.File.Direct.Requirements.Alignment.Length.self
    }

    @Test
    func `isValid method exists`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let length = alignment.length
        _ = length.isValid(ISO_9945.Kernel.File.Size(0))
    }

    @Test
    func `isValid returns true for valid lengths`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let length = alignment.length
        #expect(length.isValid(ISO_9945.Kernel.File.Size(0)) == true)
        #expect(length.isValid(ISO_9945.Kernel.File.Size(4096)) == true)
        #expect(length.isValid(ISO_9945.Kernel.File.Size(8192)) == true)
        #expect(length.isValid(ISO_9945.Kernel.File.Size(16384)) == true)
    }

    @Test
    func `isValid returns false for invalid lengths`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let length = alignment.length
        #expect(length.isValid(ISO_9945.Kernel.File.Size(1)) == false)
        #expect(length.isValid(ISO_9945.Kernel.File.Size(100)) == false)
        #expect(length.isValid(ISO_9945.Kernel.File.Size(4097)) == false)
        #expect(length.isValid(ISO_9945.Kernel.File.Size(5000)) == false)
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.File.Direct.Requirements.Alignment.Length.Test.Unit {
    @Test
    func `Length is Sendable`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let length: any Sendable = alignment.length
        #expect(length is ISO_9945.Kernel.File.Direct.Requirements.Alignment.Length)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.Direct.Requirements.Alignment.Length.Test.EdgeCase {
    @Test
    func `length accessor returns consistent value`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let length1 = alignment.length
        let length2 = alignment.length
        #expect(length1.isValid(ISO_9945.Kernel.File.Size(4096)) == length2.isValid(ISO_9945.Kernel.File.Size(4096)))
    }

    @Test
    func `zero length is always valid`() {
        let alignments: [Memory.Alignment] = [.`512`, .`1024`, .`4096`, .`8192`]
        for value in alignments {
            let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: value)
            #expect(alignment.length.isValid(ISO_9945.Kernel.File.Size(0)) == true)
        }
    }

    @Test
    func `alignment value is always valid length`() {
        let alignments: [(Memory.Alignment, ISO_9945.Kernel.File.Size)] = [
            (.`512`, ISO_9945.Kernel.File.Size(512)),
            (.`1024`, ISO_9945.Kernel.File.Size(1024)),
            (.`4096`, ISO_9945.Kernel.File.Size(4096)),
            (.`8192`, ISO_9945.Kernel.File.Size(8192)),
        ]
        for (align, value) in alignments {
            let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: align)
            #expect(alignment.length.isValid(value) == true)
        }
    }
}
