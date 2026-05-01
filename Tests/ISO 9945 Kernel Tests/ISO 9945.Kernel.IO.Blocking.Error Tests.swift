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


extension ISO_9945.Kernel.IO.Blocking.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.IO.Blocking.Error.Test.Unit {
    @Test
    func `wouldBlock case exists`() {
        let error = ISO_9945.Kernel.IO.Blocking.Error.wouldBlock
        if case .wouldBlock = error {
            // Expected
        } else {
            Issue.record("Expected .wouldBlock case")
        }
    }
}

// MARK: - Description Tests

extension ISO_9945.Kernel.IO.Blocking.Error.Test.Unit {
    @Test
    func `wouldBlock description`() {
        let error = ISO_9945.Kernel.IO.Blocking.Error.wouldBlock
        #expect(error.description == "operation would block")
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.IO.Blocking.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = ISO_9945.Kernel.IO.Blocking.Error.wouldBlock
        #expect(error is ISO_9945.Kernel.IO.Blocking.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = ISO_9945.Kernel.IO.Blocking.Error.wouldBlock
        #expect(error is ISO_9945.Kernel.IO.Blocking.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = ISO_9945.Kernel.IO.Blocking.Error.wouldBlock
        let b = ISO_9945.Kernel.IO.Blocking.Error.wouldBlock
        #expect(a == b)
    }

    @Test
    func `Error is Hashable`() {
        var set = Set<ISO_9945.Kernel.IO.Blocking.Error>()
        set.insert(.wouldBlock)
        set.insert(.wouldBlock)  // duplicate
        #expect(set.count == 1)
    }
}
