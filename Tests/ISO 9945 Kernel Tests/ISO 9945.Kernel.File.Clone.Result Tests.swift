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


extension ISO_9945.Kernel.File.Clone.Result {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.Clone.Result.Test.Unit {
    @Test
    func `reflinked case exists`() {
        let result = ISO_9945.Kernel.File.Clone.Result.reflinked
        if case .reflinked = result {
            // Expected
        } else {
            Issue.record("Expected .reflinked case")
        }
    }

    @Test
    func `copied case exists`() {
        let result = ISO_9945.Kernel.File.Clone.Result.copied
        if case .copied = result {
            // Expected
        } else {
            Issue.record("Expected .copied case")
        }
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.File.Clone.Result.Test.Unit {
    @Test
    func `Result is Sendable`() {
        let result: any Sendable = ISO_9945.Kernel.File.Clone.Result.reflinked
        #expect(result is ISO_9945.Kernel.File.Clone.Result)
    }

    @Test
    func `Result is Equatable`() {
        let a = ISO_9945.Kernel.File.Clone.Result.reflinked
        let b = ISO_9945.Kernel.File.Clone.Result.reflinked
        let c = ISO_9945.Kernel.File.Clone.Result.copied
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.Clone.Result.Test.EdgeCase {
    @Test
    func `reflinked and copied are distinct`() {
        let reflinked = ISO_9945.Kernel.File.Clone.Result.reflinked
        let copied = ISO_9945.Kernel.File.Clone.Result.copied
        #expect(reflinked != copied)
    }

    @Test
    func `all cases are distinct`() {
        let cases: [ISO_9945.Kernel.File.Clone.Result] = [
            .reflinked,
            .copied,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}
