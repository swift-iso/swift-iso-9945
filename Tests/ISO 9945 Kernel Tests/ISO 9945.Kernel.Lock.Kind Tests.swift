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


extension Kernel.Lock.Kind {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Lock.Kind.Test.Unit {
    @Test
    func `shared case exists`() {
        let kind = Kernel.Lock.Kind.shared
        if case .shared = kind {
            // Expected
        } else {
            Issue.record("Expected .shared case")
        }
    }

    @Test
    func `exclusive case exists`() {
        let kind = Kernel.Lock.Kind.exclusive
        if case .exclusive = kind {
            // Expected
        } else {
            Issue.record("Expected .exclusive case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Lock.Kind.Test.Unit {
    @Test
    func `Kind is Sendable`() {
        let kind: any Sendable = Kernel.Lock.Kind.shared
        #expect(kind is Kernel.Lock.Kind)
    }

    @Test
    func `Kind is Equatable`() {
        let a = Kernel.Lock.Kind.shared
        let b = Kernel.Lock.Kind.shared
        let c = Kernel.Lock.Kind.exclusive
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Kind is Hashable`() {
        var set = Set<Kernel.Lock.Kind>()
        set.insert(.shared)
        set.insert(.exclusive)
        set.insert(.shared)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.Lock.Kind.Test.EdgeCase {
    @Test
    func `shared and exclusive are distinct`() {
        let shared = Kernel.Lock.Kind.shared
        let exclusive = Kernel.Lock.Kind.exclusive
        #expect(shared != exclusive)
    }

    @Test
    func `hash values for different kinds are different`() {
        let sharedHash = Kernel.Lock.Kind.shared.hashValue
        let exclusiveHash = Kernel.Lock.Kind.exclusive.hashValue
        #expect(sharedHash != exclusiveHash)
    }
}
