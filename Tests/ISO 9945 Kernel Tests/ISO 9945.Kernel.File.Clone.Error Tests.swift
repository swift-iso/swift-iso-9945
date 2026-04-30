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


extension Kernel.File.Clone.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.Clone.Error.Test.Unit {
    @Test
    func `notSupported case exists`() {
        let error = Kernel.File.Clone.Error.notSupported
        if case .notSupported = error {
            // Expected
        } else {
            Issue.record("Expected .notSupported case")
        }
    }

    @Test
    func `crossDevice case exists`() {
        let error = Kernel.File.Clone.Error.crossDevice
        if case .crossDevice = error {
            // Expected
        } else {
            Issue.record("Expected .crossDevice case")
        }
    }

    @Test
    func `sourceNotFound case exists`() {
        let error = Kernel.File.Clone.Error.sourceNotFound
        if case .sourceNotFound = error {
            // Expected
        } else {
            Issue.record("Expected .sourceNotFound case")
        }
    }

    @Test
    func `destinationExists case exists`() {
        let error = Kernel.File.Clone.Error.destinationExists
        if case .destinationExists = error {
            // Expected
        } else {
            Issue.record("Expected .destinationExists case")
        }
    }

    @Test
    func `permissionDenied case exists`() {
        let error = Kernel.File.Clone.Error.permissionDenied
        if case .permissionDenied = error {
            // Expected
        } else {
            Issue.record("Expected .permissionDenied case")
        }
    }

    @Test
    func `isDirectory case exists`() {
        let error = Kernel.File.Clone.Error.isDirectory
        if case .isDirectory = error {
            // Expected
        } else {
            Issue.record("Expected .isDirectory case")
        }
    }

    @Test
    func `platform case exists`() {
        let error = Kernel.File.Clone.Error.platform(code: .posix(1), operation: .clonefile)
        if case .platform = error {
            // Expected
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.File.Clone.Error.Test.Unit {
    @Test
    func `notSupported description`() {
        let error = Kernel.File.Clone.Error.notSupported
        #expect(error.description == "Reflink not supported on this filesystem")
    }

    @Test
    func `crossDevice description`() {
        let error = Kernel.File.Clone.Error.crossDevice
        #expect(error.description == "Source and destination are on different devices")
    }

    @Test
    func `sourceNotFound description`() {
        let error = Kernel.File.Clone.Error.sourceNotFound
        #expect(error.description == "Source file not found")
    }

    @Test
    func `destinationExists description`() {
        let error = Kernel.File.Clone.Error.destinationExists
        #expect(error.description == "Destination already exists")
    }

    @Test
    func `permissionDenied description`() {
        let error = Kernel.File.Clone.Error.permissionDenied
        #expect(error.description == "Permission denied")
    }

    @Test
    func `isDirectory description`() {
        let error = Kernel.File.Clone.Error.isDirectory
        #expect(error.description == "Source is a directory")
    }

    @Test
    func `platform description includes operation`() {
        let error = Kernel.File.Clone.Error.platform(code: .posix(1), operation: .clonefile)
        #expect(error.description.contains("clonefile"))
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Clone.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = Kernel.File.Clone.Error.notSupported
        #expect(error is Kernel.File.Clone.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = Kernel.File.Clone.Error.notSupported
        #expect(error is Kernel.File.Clone.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = Kernel.File.Clone.Error.notSupported
        let b = Kernel.File.Clone.Error.notSupported
        let c = Kernel.File.Clone.Error.crossDevice
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Error is CustomStringConvertible`() {
        let error: any CustomStringConvertible = Kernel.File.Clone.Error.notSupported
        #expect(!error.description.isEmpty)
    }
}

// MARK: - Nested Types

extension Kernel.File.Clone.Error.Test.Unit {
    @Test
    func `Operation type exists`() {
        let _: Kernel.File.Clone.Error.Operation.Type = Kernel.File.Clone.Error.Operation.self
    }

    @Test
    func `Syscall type exists`() {
        let _: Kernel.File.Clone.Error.Syscall.Type = Kernel.File.Clone.Error.Syscall.self
    }
}

// MARK: - Edge Cases

extension Kernel.File.Clone.Error.Test.EdgeCase {
    @Test
    func `all simple cases are distinct`() {
        let cases: [Kernel.File.Clone.Error] = [
            .notSupported,
            .crossDevice,
            .sourceNotFound,
            .destinationExists,
            .permissionDenied,
            .isDirectory,
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test
    func `platform errors with different codes are distinct`() {
        let error1 = Kernel.File.Clone.Error.platform(code: .posix(1), operation: .clonefile)
        let error2 = Kernel.File.Clone.Error.platform(code: .posix(2), operation: .clonefile)
        #expect(error1 != error2)
    }

    @Test
    func `platform errors with different operations are distinct`() {
        let error1 = Kernel.File.Clone.Error.platform(code: .posix(1), operation: .clonefile)
        let error2 = Kernel.File.Clone.Error.platform(code: .posix(1), operation: .copyfile)
        #expect(error1 != error2)
    }

    @Test
    func `all descriptions are non-empty`() {
        let cases: [Kernel.File.Clone.Error] = [
            .notSupported,
            .crossDevice,
            .sourceNotFound,
            .destinationExists,
            .permissionDenied,
            .isDirectory,
            .platform(code: .posix(1), operation: .clonefile),
        ]

        for error in cases {
            #expect(!error.description.isEmpty)
        }
    }
}
