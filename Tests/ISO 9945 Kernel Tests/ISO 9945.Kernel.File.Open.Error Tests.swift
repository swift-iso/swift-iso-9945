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

@_spi(Syscall) import ISO_9945_Kernel
import Tagged_Primitives_Standard_Library_Integration
// Tests use Apple native Testing framework
import Testing

extension ISO_9945.Kernel.File.Open.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.Open.Error.Test.Unit {
    @Test
    func `path case stores Path.Resolution.Error`() {
        let pathError = Path.Resolution.Error.notFound
        let error = ISO_9945.Kernel.File.Open.Error.path(pathError)
        if case .path(let stored) = error {
            #expect(stored == pathError)
        } else {
            Issue.record("Expected .path case")
        }
    }

    @Test
    func `handle case stores Descriptor.Validity.Error`() {
        let handleError = ISO_9945.Kernel.Descriptor.Validity.Error.invalid
        let error = ISO_9945.Kernel.File.Open.Error.handle(handleError)
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
        let error = ISO_9945.Kernel.File.Open.Error.platform(unmappedError)
        if case .platform(let stored) = error {
            #expect(stored == unmappedError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension ISO_9945.Kernel.File.Open.Error.Test.Unit {
    @Test
    func `path description format`() {
        let error = ISO_9945.Kernel.File.Open.Error.path(.notFound)
        #expect(error.description.contains("path:"))
    }

    @Test
    func `handle description format`() {
        let error = ISO_9945.Kernel.File.Open.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.File.Open.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = ISO_9945.Kernel.File.Open.Error.path(.notFound)
        #expect(error is ISO_9945.Kernel.File.Open.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = ISO_9945.Kernel.File.Open.Error.path(.notFound)
        #expect(error is ISO_9945.Kernel.File.Open.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = ISO_9945.Kernel.File.Open.Error.path(.notFound)
        let b = ISO_9945.Kernel.File.Open.Error.path(.notFound)
        let c = ISO_9945.Kernel.File.Open.Error.path(.exists)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.Open.Error.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let cases: [ISO_9945.Kernel.File.Open.Error] = [
            .path(.notFound),
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
    func `path resolution cases are distinct`() {
        let notFound = ISO_9945.Kernel.File.Open.Error.path(.notFound)
        let exists = ISO_9945.Kernel.File.Open.Error.path(.exists)
        let isDirectory = ISO_9945.Kernel.File.Open.Error.path(.isDirectory)
        #expect(notFound != exists)
        #expect(exists != isDirectory)
    }
}

// MARK: - POSIX Error Mapping (Fold) Tests
//
// Per the ratified 3-case shape (.path, .handle, .platform — Path X Cycle 18g
// dropped .space; commit 6c67958), init(code:) cascades path -> descriptor ->
// .platform only. Codes that used to route to dedicated .permission/.space/.io
// cases now fold into .platform.

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.File.Open.Error.Test.Unit {
    @Test
    func `permission-classed code (EACCES) folds into platform`() {
        let error = ISO_9945.Kernel.File.Open.Error(code: .posix(EACCES))
        if case .platform = error {
            // Expected: EACCES is not path- or handle-mapped, so it cascades
            // through to .platform under the ratified 3-case shape.
        } else {
            Issue.record("Expected .platform case for EACCES")
        }
    }

    @Test
    func `space-classed code (ENOSPC) folds into platform`() {
        let error = ISO_9945.Kernel.File.Open.Error(code: .posix(ENOSPC))
        if case .platform = error {
            // Expected: ENOSPC is not path- or handle-mapped, so it cascades
            // through to .platform under the ratified 3-case shape.
        } else {
            Issue.record("Expected .platform case for ENOSPC")
        }
    }

    @Test
    func `io-classed code (EIO) folds into platform`() {
        let error = ISO_9945.Kernel.File.Open.Error(code: .posix(EIO))
        if case .platform = error {
            // Expected: EIO is not path- or handle-mapped, so it cascades
            // through to .platform under the ratified 3-case shape.
        } else {
            Issue.record("Expected .platform case for EIO")
        }
    }
}
