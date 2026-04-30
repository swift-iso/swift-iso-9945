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


extension Kernel.File.Stats.Kind.Link {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.Stats.Kind.Link.Test.Unit {
    @Test
    func `symbolic case exists`() {
        let link = Kernel.File.Stats.Kind.Link.symbolic
        if case .symbolic = link {
            // Expected
        } else {
            Issue.record("Expected .symbolic case")
        }
    }

    @Test
    func `junction case exists`() {
        let link = Kernel.File.Stats.Kind.Link.junction
        if case .junction = link {
            // Expected
        } else {
            Issue.record("Expected .junction case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Stats.Kind.Link.Test.Unit {
    @Test
    func `Link is Sendable`() {
        let link: any Sendable = Kernel.File.Stats.Kind.Link.symbolic
        #expect(link is Kernel.File.Stats.Kind.Link)
    }

    @Test
    func `Link is Equatable`() {
        let a = Kernel.File.Stats.Kind.Link.symbolic
        let b = Kernel.File.Stats.Kind.Link.symbolic
        let c = Kernel.File.Stats.Kind.Link.junction
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Link is Hashable`() {
        var set = Set<Kernel.File.Stats.Kind.Link>()
        set.insert(.symbolic)
        set.insert(.junction)
        set.insert(.symbolic)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Stats.Kind.Link.Test.EdgeCase {
    @Test
    func `symbolic and junction are distinct`() {
        let symbolic = Kernel.File.Stats.Kind.Link.symbolic
        let junction = Kernel.File.Stats.Kind.Link.junction
        #expect(symbolic != junction)
    }
}
