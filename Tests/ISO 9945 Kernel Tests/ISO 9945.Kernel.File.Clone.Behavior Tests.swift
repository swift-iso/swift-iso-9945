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


extension Kernel.File.Clone.Behavior {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.Clone.Behavior.Test.Unit {
    @Test
    func `reflinkOrFail case exists`() {
        let behavior = Kernel.File.Clone.Behavior.reflinkOrFail
        if case .reflinkOrFail = behavior {
            // Expected
        } else {
            Issue.record("Expected .reflinkOrFail case")
        }
    }

    @Test
    func `reflinkOrCopy case exists`() {
        let behavior = Kernel.File.Clone.Behavior.reflinkOrCopy
        if case .reflinkOrCopy = behavior {
            // Expected
        } else {
            Issue.record("Expected .reflinkOrCopy case")
        }
    }

    @Test
    func `copyOnly case exists`() {
        let behavior = Kernel.File.Clone.Behavior.copyOnly
        if case .copyOnly = behavior {
            // Expected
        } else {
            Issue.record("Expected .copyOnly case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Clone.Behavior.Test.Unit {
    @Test
    func `Behavior is Sendable`() {
        let behavior: any Sendable = Kernel.File.Clone.Behavior.reflinkOrCopy
        #expect(behavior is Kernel.File.Clone.Behavior)
    }

    @Test
    func `Behavior is Equatable`() {
        let a = Kernel.File.Clone.Behavior.reflinkOrCopy
        let b = Kernel.File.Clone.Behavior.reflinkOrCopy
        let c = Kernel.File.Clone.Behavior.copyOnly
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Clone.Behavior.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let cases: [Kernel.File.Clone.Behavior] = [
            .reflinkOrFail,
            .reflinkOrCopy,
            .copyOnly,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}
