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


extension Kernel.File.Open.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.Open.Error.Test.Unit {
    @Test
    func `path case stores Path.Resolution.Error`() {
        let pathError = Path.Resolution.Error.notFound
        let error = Kernel.File.Open.Error.path(pathError)
        if case .path(let stored) = error {
            #expect(stored == pathError)
        } else {
            Issue.record("Expected .path case")
        }
    }

    @Test
    func `permission case stores Permission.Error`() {
        let permError = Kernel.Permission.Error.denied
        let error = Kernel.File.Open.Error.permission(permError)
        if case .permission(let stored) = error {
            #expect(stored == permError)
        } else {
            Issue.record("Expected .permission case")
        }
    }

    @Test
    func `handle case stores Descriptor.Validity.Error`() {
        let handleError = Kernel.Descriptor.Validity.Error.invalid
        let error = Kernel.File.Open.Error.handle(handleError)
        if case .handle(let stored) = error {
            #expect(stored == handleError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test
    func `space case stores Storage.Error`() {
        let spaceError = Kernel.Storage.Error.exhausted
        let error = Kernel.File.Open.Error.space(spaceError)
        if case .space(let stored) = error {
            #expect(stored == spaceError)
        } else {
            Issue.record("Expected .space case")
        }
    }

    @Test
    func `io case stores IO.Error`() {
        let ioError = Kernel.IO.Error.hardware
        let error = Kernel.File.Open.Error.io(ioError)
        if case .io(let stored) = error {
            #expect(stored == ioError)
        } else {
            Issue.record("Expected .io case")
        }
    }

    @Test
    func `platform case stores Error_Primitives.Error`() {
        let code = Error_Primitives.Error.Code.posix(999)
        let unmappedError = Error_Primitives.Error(code: code)
        let error = Kernel.File.Open.Error.platform(unmappedError)
        if case .platform(let stored) = error {
            #expect(stored == unmappedError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.File.Open.Error.Test.Unit {
    @Test
    func `path description format`() {
        let error = Kernel.File.Open.Error.path(.notFound)
        #expect(error.description.contains("path:"))
    }

    @Test
    func `permission description format`() {
        let error = Kernel.File.Open.Error.permission(.denied)
        #expect(error.description.contains("permission:"))
    }

    @Test
    func `handle description format`() {
        let error = Kernel.File.Open.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }

    @Test
    func `space description format`() {
        let error = Kernel.File.Open.Error.space(.exhausted)
        #expect(error.description.contains("space:"))
    }

    @Test
    func `io description format`() {
        let error = Kernel.File.Open.Error.io(.hardware)
        #expect(error.description.contains("io:"))
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Open.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = Kernel.File.Open.Error.path(.notFound)
        #expect(error is Kernel.File.Open.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = Kernel.File.Open.Error.path(.notFound)
        #expect(error is Kernel.File.Open.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = Kernel.File.Open.Error.path(.notFound)
        let b = Kernel.File.Open.Error.path(.notFound)
        let c = Kernel.File.Open.Error.path(.exists)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Open.Error.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let cases: [Kernel.File.Open.Error] = [
            .path(.notFound),
            .permission(.denied),
            .handle(.invalid),
            .space(.exhausted),
            .io(.hardware),
            .platform(Error_Primitives.Error(code: .posix(1))),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test
    func `path resolution cases are distinct`() {
        let notFound = Kernel.File.Open.Error.path(.notFound)
        let exists = Kernel.File.Open.Error.path(.exists)
        let isDirectory = Kernel.File.Open.Error.path(.isDirectory)
        #expect(notFound != exists)
        #expect(exists != isDirectory)
    }

    @Test
    func `permission cases are distinct`() {
        let denied = Kernel.File.Open.Error.permission(.denied)
        let notPermitted = Kernel.File.Open.Error.permission(.notPermitted)
        let readOnly = Kernel.File.Open.Error.permission(.readOnlyFilesystem)
        #expect(denied != notPermitted)
        #expect(notPermitted != readOnly)
    }
}
