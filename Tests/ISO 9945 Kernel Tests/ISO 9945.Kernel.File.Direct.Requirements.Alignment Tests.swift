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

import ISO_9945_Kernel
import Tagged_Primitives_Standard_Library_Integration
// Tests use Apple native Testing framework
import Testing

extension ISO_9945.Kernel.File.Direct.Requirements.Alignment {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.Direct.Requirements.Alignment.Test.Unit {
    @Test
    func `init with explicit values`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`512`,
            offsetAlignment: .`4096`,
            lengthMultiple: .`512`
        )
        #expect(alignment.bufferAlignment == .`512`)
        #expect(alignment.offsetAlignment == .`4096`)
        #expect(alignment.lengthMultiple == .`512`)
    }

    @Test
    func `init with uniform alignment`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        #expect(alignment.bufferAlignment == .`4096`)
        #expect(alignment.offsetAlignment == .`4096`)
        #expect(alignment.lengthMultiple == .`4096`)
    }

    @Test
    func `bufferAlignment property`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`512`)
        #expect(alignment.bufferAlignment == .`512`)
    }

    @Test
    func `offsetAlignment property`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        #expect(alignment.offsetAlignment == .`4096`)
    }

    @Test
    func `lengthMultiple property`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        #expect(alignment.lengthMultiple == .`4096`)
    }
}

// MARK: - Accessor Tests

extension ISO_9945.Kernel.File.Direct.Requirements.Alignment.Test.Unit {
    @Test
    func `buffer accessor exists`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let _ = alignment.buffer
    }

    @Test
    func `offset accessor exists`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let _ = alignment.offset
    }

    @Test
    func `length accessor exists`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let _ = alignment.length
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.File.Direct.Requirements.Alignment.Test.Unit {
    @Test
    func `Alignment is Sendable`() {
        let alignment: any Sendable = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        #expect(alignment is ISO_9945.Kernel.File.Direct.Requirements.Alignment)
    }

    @Test
    func `Alignment is Equatable`() {
        let a = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let b = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let c = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`512`)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.Direct.Requirements.Alignment.Test.EdgeCase {
    @Test
    func `alignments with different buffer values are distinct`() {
        let a = ISO_9945.Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`512`,
            offsetAlignment: .`4096`,
            lengthMultiple: .`4096`
        )
        let b = ISO_9945.Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`4096`,
            offsetAlignment: .`4096`,
            lengthMultiple: .`4096`
        )
        #expect(a != b)
    }

    @Test
    func `alignments with different offset values are distinct`() {
        let a = ISO_9945.Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`4096`,
            offsetAlignment: .`512`,
            lengthMultiple: .`4096`
        )
        let b = ISO_9945.Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`4096`,
            offsetAlignment: .`4096`,
            lengthMultiple: .`4096`
        )
        #expect(a != b)
    }

    @Test
    func `alignments with different length values are distinct`() {
        let a = ISO_9945.Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`4096`,
            offsetAlignment: .`4096`,
            lengthMultiple: .`512`
        )
        let b = ISO_9945.Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`4096`,
            offsetAlignment: .`4096`,
            lengthMultiple: .`4096`
        )
        #expect(a != b)
    }

    @Test
    func `uniform alignment equals explicit with same values`() {
        let uniform = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let explicit = ISO_9945.Kernel.File.Direct.Requirements.Alignment(
            bufferAlignment: .`4096`,
            offsetAlignment: .`4096`,
            lengthMultiple: .`4096`
        )
        #expect(uniform == explicit)
    }
}
