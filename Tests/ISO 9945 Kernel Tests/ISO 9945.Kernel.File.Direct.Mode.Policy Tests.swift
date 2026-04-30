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


extension Kernel.File.Direct.Mode.Policy {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Mode.Policy.Test.Unit {
    @Test
    func `fallbackToBuffered case exists`() {
        let policy = Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        if case .fallbackToBuffered = policy {
            // Expected
        } else {
            Issue.record("Expected .fallbackToBuffered case")
        }
    }

    @Test
    func `errorOnViolation case exists`() {
        let policy = Kernel.File.Direct.Mode.Policy.errorOnViolation
        if case .errorOnViolation = policy {
            // Expected
        } else {
            Issue.record("Expected .errorOnViolation case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Direct.Mode.Policy.Test.Unit {
    @Test
    func `Policy is Sendable`() {
        let policy: any Sendable = Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        #expect(policy is Kernel.File.Direct.Mode.Policy)
    }

    @Test
    func `Policy is Equatable`() {
        let a = Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        let b = Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        let c = Kernel.File.Direct.Mode.Policy.errorOnViolation
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Direct.Mode.Policy.Test.EdgeCase {
    @Test
    func `all policies are distinct`() {
        let fallback = Kernel.File.Direct.Mode.Policy.fallbackToBuffered
        let error = Kernel.File.Direct.Mode.Policy.errorOnViolation
        #expect(fallback != error)
    }
}
