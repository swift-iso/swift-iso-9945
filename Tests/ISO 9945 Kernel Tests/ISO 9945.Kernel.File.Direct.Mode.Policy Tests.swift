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


extension ISO_9945.Kernel.File.Direct.Mode.Policy {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.Direct.Mode.Policy.Test.Unit {
    @Test
    func `fallbackToBuffered case exists`() {
        let policy = ISO_9945.Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        if case .fallbackToBuffered = policy {
            // Expected
        } else {
            Issue.record("Expected .fallbackToBuffered case")
        }
    }

    @Test
    func `errorOnViolation case exists`() {
        let policy = ISO_9945.Kernel.File.Direct.Mode.Policy.errorOnViolation
        if case .errorOnViolation = policy {
            // Expected
        } else {
            Issue.record("Expected .errorOnViolation case")
        }
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.File.Direct.Mode.Policy.Test.Unit {
    @Test
    func `Policy is Sendable`() {
        let policy: any Sendable = ISO_9945.Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        #expect(policy is ISO_9945.Kernel.File.Direct.Mode.Policy)
    }

    @Test
    func `Policy is Equatable`() {
        let a = ISO_9945.Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        let b = ISO_9945.Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        let c = ISO_9945.Kernel.File.Direct.Mode.Policy.errorOnViolation
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.Direct.Mode.Policy.Test.EdgeCase {
    @Test
    func `all policies are distinct`() {
        let fallback = ISO_9945.Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        let error = ISO_9945.Kernel.File.Direct.Mode.Policy.errorOnViolation
        #expect(fallback != error)
    }
}
