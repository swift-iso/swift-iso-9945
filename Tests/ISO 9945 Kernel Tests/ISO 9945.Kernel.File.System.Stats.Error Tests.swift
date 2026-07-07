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

extension ISO_9945.Kernel.File.System.Stats.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.System.Stats.Error.Test.Unit {
    @Test
    func `path case exists`() {
        let error = ISO_9945.Kernel.File.System.Stats.Error.path(.notFound)
        if case .path = error {
            // Expected
        } else {
            Issue.record("Expected .path case")
        }
    }

    @Test
    func `handle case exists`() {
        let error = ISO_9945.Kernel.File.System.Stats.Error.handle(.invalid)
        if case .handle = error {
            // Expected
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test
    func `permission case exists`() {
        let error = ISO_9945.Kernel.File.System.Stats.Error.permission(.denied)
        if case .permission = error {
            // Expected
        } else {
            Issue.record("Expected .permission case")
        }
    }

    @Test
    func `io case exists`() {
        let error = ISO_9945.Kernel.File.System.Stats.Error.io(.hardware)
        if case .io = error {
            // Expected
        } else {
            Issue.record("Expected .io case")
        }
    }

    @Test
    func `platform case exists`() {
        let code = Error_Primitives.Error.Code.posix(999)
        let unmapped = Error_Primitives.Error(code: code)
        let error = ISO_9945.Kernel.File.System.Stats.Error.platform(unmapped)
        if case .platform = error {
            // Expected
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension ISO_9945.Kernel.File.System.Stats.Error.Test.Unit {
    @Test
    func `path description format`() {
        let error = ISO_9945.Kernel.File.System.Stats.Error.path(.notFound)
        #expect(error.description.contains("path:"))
    }

    @Test
    func `handle description format`() {
        let error = ISO_9945.Kernel.File.System.Stats.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }

    @Test
    func `permission description format`() {
        let error = ISO_9945.Kernel.File.System.Stats.Error.permission(.denied)
        #expect(error.description.contains("permission:"))
    }

    @Test
    func `io description format`() {
        let error = ISO_9945.Kernel.File.System.Stats.Error.io(.hardware)
        #expect(error.description.contains("io:"))
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.File.System.Stats.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = ISO_9945.Kernel.File.System.Stats.Error.handle(.invalid)
        #expect(error is ISO_9945.Kernel.File.System.Stats.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = ISO_9945.Kernel.File.System.Stats.Error.handle(.invalid)
        #expect(error is ISO_9945.Kernel.File.System.Stats.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = ISO_9945.Kernel.File.System.Stats.Error.handle(.invalid)
        let b = ISO_9945.Kernel.File.System.Stats.Error.handle(.invalid)
        let c = ISO_9945.Kernel.File.System.Stats.Error.io(.hardware)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Error is CustomStringConvertible`() {
        let error: any CustomStringConvertible = ISO_9945.Kernel.File.System.Stats.Error.handle(.invalid)
        #expect(!error.description.isEmpty)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.System.Stats.Error.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let code = Error_Primitives.Error.Code.posix(999)
        let unmapped = Error_Primitives.Error(code: code)

        let cases: [ISO_9945.Kernel.File.System.Stats.Error] = [
            .path(.notFound),
            .handle(.invalid),
            .permission(.denied),
            .io(.hardware),
            .platform(unmapped),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test
    func `different path errors are distinct`() {
        let notFound = ISO_9945.Kernel.File.System.Stats.Error.path(.notFound)
        let tooLong = ISO_9945.Kernel.File.System.Stats.Error.path(.nameTooLong)
        #expect(notFound != tooLong)
    }

    @Test
    func `different handle errors are distinct`() {
        let invalid = ISO_9945.Kernel.File.System.Stats.Error.handle(.invalid)
        let processLimit = ISO_9945.Kernel.File.System.Stats.Error.handle(.limit(.process))
        #expect(invalid != processLimit)
    }

    @Test
    func `different io errors are distinct`() {
        let hardware = ISO_9945.Kernel.File.System.Stats.Error.io(.hardware)
        let broken = ISO_9945.Kernel.File.System.Stats.Error.io(.broken)
        #expect(hardware != broken)
    }

    @Test
    func `all descriptions are non-empty`() {
        let code = Error_Primitives.Error.Code.posix(999)
        let unmapped = Error_Primitives.Error(code: code)

        let cases: [ISO_9945.Kernel.File.System.Stats.Error] = [
            .path(.notFound),
            .handle(.invalid),
            .permission(.denied),
            .io(.hardware),
            .platform(unmapped),
        ]

        for error in cases {
            #expect(!error.description.isEmpty)
        }
    }
}
