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

extension ISO_9945.Kernel.File.Direct.Capability {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.Direct.Capability.Test.Unit {
    @Test
    func `directSupported case exists`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let capability = ISO_9945.Kernel.File.Direct.Capability.directSupported(alignment)
        if case .directSupported = capability {
            // Expected
        } else {
            Issue.record("Expected .directSupported case")
        }
    }

    @Test
    func `uncachedOnly case exists`() {
        let capability = ISO_9945.Kernel.File.Direct.Capability.uncachedOnly
        if case .uncachedOnly = capability {
            // Expected
        } else {
            Issue.record("Expected .uncachedOnly case")
        }
    }

    @Test
    func `bufferedOnly case exists`() {
        let capability = ISO_9945.Kernel.File.Direct.Capability.bufferedOnly
        if case .bufferedOnly = capability {
            // Expected
        } else {
            Issue.record("Expected .bufferedOnly case")
        }
    }
}

// MARK: - Accessor Tests

extension ISO_9945.Kernel.File.Direct.Capability.Test.Unit {
    @Test
    func `direct.isSupported returns true for directSupported`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let capability = ISO_9945.Kernel.File.Direct.Capability.directSupported(alignment)
        #expect(capability.direct.isSupported == true)
    }

    @Test
    func `direct.isSupported returns false for uncachedOnly`() {
        let capability = ISO_9945.Kernel.File.Direct.Capability.uncachedOnly
        #expect(capability.direct.isSupported == false)
    }

    @Test
    func `direct.isSupported returns false for bufferedOnly`() {
        let capability = ISO_9945.Kernel.File.Direct.Capability.bufferedOnly
        #expect(capability.direct.isSupported == false)
    }

    @Test
    func `bypass.isSupported returns true for directSupported`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let capability = ISO_9945.Kernel.File.Direct.Capability.directSupported(alignment)
        #expect(capability.bypass.isSupported == true)
    }

    @Test
    func `bypass.isSupported returns true for uncachedOnly`() {
        let capability = ISO_9945.Kernel.File.Direct.Capability.uncachedOnly
        #expect(capability.bypass.isSupported == true)
    }

    @Test
    func `bypass.isSupported returns false for bufferedOnly`() {
        let capability = ISO_9945.Kernel.File.Direct.Capability.bufferedOnly
        #expect(capability.bypass.isSupported == false)
    }

    @Test
    func `alignment returns value for directSupported`() {
        let alignment = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let capability = ISO_9945.Kernel.File.Direct.Capability.directSupported(alignment)
        #expect(capability.alignment != nil)
        #expect(capability.alignment?.bufferAlignment == .`4096`)
    }

    @Test
    func `alignment returns nil for uncachedOnly`() {
        let capability = ISO_9945.Kernel.File.Direct.Capability.uncachedOnly
        #expect(capability.alignment == nil)
    }

    @Test
    func `alignment returns nil for bufferedOnly`() {
        let capability = ISO_9945.Kernel.File.Direct.Capability.bufferedOnly
        #expect(capability.alignment == nil)
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.File.Direct.Capability.Test.Unit {
    @Test
    func `Capability is Sendable`() {
        let capability: any Sendable = ISO_9945.Kernel.File.Direct.Capability.uncachedOnly
        #expect(capability is ISO_9945.Kernel.File.Direct.Capability)
    }

    @Test
    func `Capability is Equatable`() {
        let a = ISO_9945.Kernel.File.Direct.Capability.uncachedOnly
        let b = ISO_9945.Kernel.File.Direct.Capability.uncachedOnly
        let c = ISO_9945.Kernel.File.Direct.Capability.bufferedOnly
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.Direct.Capability.Test.EdgeCase {
    @Test
    func `all simple cases are distinct`() {
        let uncached = ISO_9945.Kernel.File.Direct.Capability.uncachedOnly
        let buffered = ISO_9945.Kernel.File.Direct.Capability.bufferedOnly
        #expect(uncached != buffered)
    }

    @Test
    func `directSupported with different alignments are distinct`() {
        let align1 = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`512`)
        let align2 = ISO_9945.Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let cap1 = ISO_9945.Kernel.File.Direct.Capability.directSupported(align1)
        let cap2 = ISO_9945.Kernel.File.Direct.Capability.directSupported(align2)
        #expect(cap1 != cap2)
    }
}
