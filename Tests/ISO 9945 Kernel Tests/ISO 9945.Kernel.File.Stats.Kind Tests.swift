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


extension Kernel.File.Stats.Kind {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.Stats.Kind.Test.Unit {
    @Test
    func `regular case exists`() {
        let kind = Kernel.File.Stats.Kind.regular
        if case .regular = kind {
            // Expected
        } else {
            Issue.record("Expected .regular case")
        }
    }

    @Test
    func `directory case exists`() {
        let kind = Kernel.File.Stats.Kind.directory
        if case .directory = kind {
            // Expected
        } else {
            Issue.record("Expected .directory case")
        }
    }

    @Test
    func `link case exists`() {
        let kind = Kernel.File.Stats.Kind.link(.symbolic)
        if case .link = kind {
            // Expected
        } else {
            Issue.record("Expected .link case")
        }
    }

    @Test
    func `device case exists`() {
        let kind = Kernel.File.Stats.Kind.device(.block)
        if case .device = kind {
            // Expected
        } else {
            Issue.record("Expected .device case")
        }
    }

    @Test
    func `fifo case exists`() {
        let kind = Kernel.File.Stats.Kind.fifo
        if case .fifo = kind {
            // Expected
        } else {
            Issue.record("Expected .fifo case")
        }
    }

    @Test
    func `socket case exists`() {
        let kind = Kernel.File.Stats.Kind.socket
        if case .socket = kind {
            // Expected
        } else {
            Issue.record("Expected .socket case")
        }
    }

    @Test
    func `unknown case exists`() {
        let kind = Kernel.File.Stats.Kind.unknown
        if case .unknown = kind {
            // Expected
        } else {
            Issue.record("Expected .unknown case")
        }
    }
}

// MARK: - Nested Types

extension Kernel.File.Stats.Kind.Test.Unit {
    @Test
    func `Device type exists`() {
        let _: Kernel.File.Stats.Kind.Device.Type = Kernel.File.Stats.Kind.Device.self
    }

    @Test
    func `Link type exists`() {
        let _: Kernel.File.Stats.Kind.Link.Type = Kernel.File.Stats.Kind.Link.self
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Stats.Kind.Test.Unit {
    @Test
    func `Kind is Sendable`() {
        let kind: any Sendable = Kernel.File.Stats.Kind.regular
        #expect(kind is Kernel.File.Stats.Kind)
    }

    @Test
    func `Kind is Equatable`() {
        let a = Kernel.File.Stats.Kind.regular
        let b = Kernel.File.Stats.Kind.regular
        let c = Kernel.File.Stats.Kind.directory
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Kind is Hashable`() {
        var set = Set<Kernel.File.Stats.Kind>()
        set.insert(.regular)
        set.insert(.directory)
        set.insert(.regular)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Stats.Kind.Test.EdgeCase {
    @Test
    func `all simple cases are distinct`() {
        let cases: [Kernel.File.Stats.Kind] = [
            .regular,
            .directory,
            .fifo,
            .socket,
            .unknown,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test
    func `link cases with different types are distinct`() {
        let symbolic = Kernel.File.Stats.Kind.link(.symbolic)
        let junction = Kernel.File.Stats.Kind.link(.junction)
        #expect(symbolic != junction)
    }

    @Test
    func `device cases with different types are distinct`() {
        let block = Kernel.File.Stats.Kind.device(.block)
        let character = Kernel.File.Stats.Kind.device(.character)
        #expect(block != character)
    }

    @Test
    func `link and device are distinct from simple cases`() {
        let link = Kernel.File.Stats.Kind.link(.symbolic)
        let device = Kernel.File.Stats.Kind.device(.block)
        let regular = Kernel.File.Stats.Kind.regular

        #expect(link != regular)
        #expect(device != regular)
        #expect(link != device)
    }
}
