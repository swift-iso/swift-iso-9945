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

import ISO_9945_Kernel
import Tagged_Primitives_Standard_Library_Integration
// Tests use Apple native Testing framework
import Testing

extension ISO_9945.Kernel.File.Stats.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.Stats.Error.Test.Unit {
    @Test
    func `handle case stores Descriptor.Validity.Error`() {
        let handleError = ISO_9945.Kernel.Descriptor.Validity.Error.invalid
        let error = ISO_9945.Kernel.File.Stats.Error.handle(handleError)
        if case .handle(let stored) = error {
            #expect(stored == handleError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test
    func `platform case stores Error_Primitives.Error`() {
        let code = Error_Primitives.Error.Code.posix(999)
        let unmappedError = Error_Primitives.Error(code: code)
        let error = ISO_9945.Kernel.File.Stats.Error.platform(unmappedError)
        if case .platform(let stored) = error {
            #expect(stored == unmappedError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension ISO_9945.Kernel.File.Stats.Error.Test.Unit {
    @Test
    func `handle description format`() {
        let error = ISO_9945.Kernel.File.Stats.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }

}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.File.Stats.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = ISO_9945.Kernel.File.Stats.Error.handle(.invalid)
        #expect(error is ISO_9945.Kernel.File.Stats.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = ISO_9945.Kernel.File.Stats.Error.handle(.invalid)
        #expect(error is ISO_9945.Kernel.File.Stats.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = ISO_9945.Kernel.File.Stats.Error.handle(.invalid)
        let b = ISO_9945.Kernel.File.Stats.Error.handle(.invalid)
        let c = ISO_9945.Kernel.File.Stats.Error.platform(Error_Primitives.Error(code: .posix(2)))
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.Stats.Error.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let cases: [ISO_9945.Kernel.File.Stats.Error] = [
            .handle(.invalid),
            .platform(Error_Primitives.Error(code: .posix(1))),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test
    func `handle invalid vs limit are distinct`() {
        let invalid = ISO_9945.Kernel.File.Stats.Error.handle(.invalid)
        let processLimit = ISO_9945.Kernel.File.Stats.Error.handle(.limit(.process))
        let systemLimit = ISO_9945.Kernel.File.Stats.Error.handle(.limit(.system))
        #expect(invalid != processLimit)
        #expect(processLimit != systemLimit)
    }

}
