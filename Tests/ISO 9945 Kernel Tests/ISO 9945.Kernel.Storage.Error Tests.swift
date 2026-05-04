// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Tests use Apple native Testing framework
import Testing
import Tagged_Primitives_Standard_Library_Integration
import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import Path_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Storage.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Storage.Error.Test.Unit {
    @Test
    func `Error type exists`() {
        let _: ISO_9945.Kernel.Storage.Error.Type = ISO_9945.Kernel.Storage.Error.self
    }

    @Test
    func `exhausted case exists`() {
        let error = ISO_9945.Kernel.Storage.Error.exhausted
        if case .exhausted = error {
            // Expected
        } else {
            Issue.record("Expected .exhausted case")
        }
    }

    @Test
    func `quota case exists`() {
        let error = ISO_9945.Kernel.Storage.Error.quota
        if case .quota = error {
            // Expected
        } else {
            Issue.record("Expected .quota case")
        }
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.Storage.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = ISO_9945.Kernel.Storage.Error.exhausted
        #expect(error is ISO_9945.Kernel.Storage.Error)
    }

    @Test
    func `Error is Sendable`() {
        let value: any Sendable = ISO_9945.Kernel.Storage.Error.exhausted
        #expect(value is ISO_9945.Kernel.Storage.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = ISO_9945.Kernel.Storage.Error.exhausted
        let b = ISO_9945.Kernel.Storage.Error.exhausted
        let c = ISO_9945.Kernel.Storage.Error.quota
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Error is Hashable`() {
        var set = Set<ISO_9945.Kernel.Storage.Error>()
        set.insert(.exhausted)
        set.insert(.quota)
        set.insert(.exhausted)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Description Tests

extension ISO_9945.Kernel.Storage.Error.Test.Unit {
    @Test
    func `exhausted description`() {
        let error = ISO_9945.Kernel.Storage.Error.exhausted
        #expect(error.description == "no space left on device")
    }

    @Test
    func `quota description`() {
        let error = ISO_9945.Kernel.Storage.Error.quota
        #expect(error.description == "disk quota exceeded")
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.Storage.Error.Test.EdgeCase {
    @Test
    func `All cases are distinct`() {
        let cases: [ISO_9945.Kernel.Storage.Error] = [.exhausted, .quota]
        let uniqueCases = Set(cases)
        #expect(uniqueCases.count == cases.count)
    }

    @Test
    func `CustomStringConvertible works for all cases`() {
        let cases: [ISO_9945.Kernel.Storage.Error] = [.exhausted, .quota]
        for error in cases {
            let description = Swift.String(describing: error)
            #expect(!description.isEmpty)
        }
    }
}
