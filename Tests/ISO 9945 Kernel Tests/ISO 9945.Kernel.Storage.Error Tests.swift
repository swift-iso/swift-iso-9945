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
import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import Kernel_Primitives_Core
import Kernel_Descriptor_Primitives
import Kernel_Event_Primitives
import Kernel_File_Primitives
import Path_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension Kernel.Storage.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Storage.Error.Test.Unit {
    @Test
    func `Error type exists`() {
        let _: Kernel.Storage.Error.Type = Kernel.Storage.Error.self
    }

    @Test
    func `exhausted case exists`() {
        let error = Kernel.Storage.Error.exhausted
        if case .exhausted = error {
            // Expected
        } else {
            Issue.record("Expected .exhausted case")
        }
    }

    @Test
    func `quota case exists`() {
        let error = Kernel.Storage.Error.quota
        if case .quota = error {
            // Expected
        } else {
            Issue.record("Expected .quota case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Storage.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = Kernel.Storage.Error.exhausted
        #expect(error is Kernel.Storage.Error)
    }

    @Test
    func `Error is Sendable`() {
        let value: any Sendable = Kernel.Storage.Error.exhausted
        #expect(value is Kernel.Storage.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = Kernel.Storage.Error.exhausted
        let b = Kernel.Storage.Error.exhausted
        let c = Kernel.Storage.Error.quota
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Error is Hashable`() {
        var set = Set<Kernel.Storage.Error>()
        set.insert(.exhausted)
        set.insert(.quota)
        set.insert(.exhausted)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Description Tests

extension Kernel.Storage.Error.Test.Unit {
    @Test
    func `exhausted description`() {
        let error = Kernel.Storage.Error.exhausted
        #expect(error.description == "no space left on device")
    }

    @Test
    func `quota description`() {
        let error = Kernel.Storage.Error.quota
        #expect(error.description == "disk quota exceeded")
    }
}

// MARK: - Edge Cases

extension Kernel.Storage.Error.Test.EdgeCase {
    @Test
    func `All cases are distinct`() {
        let cases: [Kernel.Storage.Error] = [.exhausted, .quota]
        let uniqueCases = Set(cases)
        #expect(uniqueCases.count == cases.count)
    }

    @Test
    func `CustomStringConvertible works for all cases`() {
        let cases: [Kernel.Storage.Error] = [.exhausted, .quota]
        for error in cases {
            let description = Swift.String(describing: error)
            #expect(!description.isEmpty)
        }
    }
}
