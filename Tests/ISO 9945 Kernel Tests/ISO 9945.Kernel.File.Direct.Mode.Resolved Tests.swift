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


extension ISO_9945.Kernel.File.Direct.Mode.Resolved {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.Direct.Mode.Resolved.Test.Unit {
    @Test
    func `direct case exists`() {
        let resolved = ISO_9945.Kernel.File.Direct.Mode.Resolved.direct
        if case .direct = resolved {
            // Expected
        } else {
            Issue.record("Expected .direct case")
        }
    }

    @Test
    func `uncached case exists`() {
        let resolved = ISO_9945.Kernel.File.Direct.Mode.Resolved.uncached
        if case .uncached = resolved {
            // Expected
        } else {
            Issue.record("Expected .uncached case")
        }
    }

    @Test
    func `buffered case exists`() {
        let resolved = ISO_9945.Kernel.File.Direct.Mode.Resolved.buffered
        if case .buffered = resolved {
            // Expected
        } else {
            Issue.record("Expected .buffered case")
        }
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.File.Direct.Mode.Resolved.Test.Unit {
    @Test
    func `Resolved is Sendable`() {
        let resolved: any Sendable = ISO_9945.Kernel.File.Direct.Mode.Resolved.buffered
        #expect(resolved is ISO_9945.Kernel.File.Direct.Mode.Resolved)
    }

    @Test
    func `Resolved is Equatable`() {
        let a = ISO_9945.Kernel.File.Direct.Mode.Resolved.buffered
        let b = ISO_9945.Kernel.File.Direct.Mode.Resolved.buffered
        let c = ISO_9945.Kernel.File.Direct.Mode.Resolved.direct
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.Direct.Mode.Resolved.Test.EdgeCase {
    @Test
    func `all resolved modes are distinct`() {
        let cases: [ISO_9945.Kernel.File.Direct.Mode.Resolved] = [
            .direct,
            .uncached,
            .buffered,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}
