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

extension ISO_9945.Kernel.IO.Read.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.IO.Read.Error.Test.Unit {
    @Test
    func `handle case stores Descriptor.Validity.Error`() {
        let validityError = ISO_9945.Kernel.Descriptor.Validity.Error.invalid
        let error = ISO_9945.Kernel.IO.Read.Error.handle(validityError)
        if case .handle(let stored) = error {
            #expect(stored == validityError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test
    func `blocking case stores IO.Blocking.Error`() {
        let blockingError = ISO_9945.Kernel.IO.Blocking.Error.wouldBlock
        let error = ISO_9945.Kernel.IO.Read.Error.blocking(blockingError)
        if case .blocking(let stored) = error {
            #expect(stored == blockingError)
        } else {
            Issue.record("Expected .blocking case")
        }
    }

    @Test
    func `platform case stores Error_Primitives.Error`() {
        let code = Error_Primitives.Error.Code.posix(999)
        let unmappedError = Error_Primitives.Error(code: code)
        let error = ISO_9945.Kernel.IO.Read.Error.platform(unmappedError)
        if case .platform(let stored) = error {
            #expect(stored == unmappedError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension ISO_9945.Kernel.IO.Read.Error.Test.Unit {
    @Test
    func `handle description format`() {
        let error = ISO_9945.Kernel.IO.Read.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }

    @Test
    func `blocking description format`() {
        let error = ISO_9945.Kernel.IO.Read.Error.blocking(.wouldBlock)
        #expect(error.description.contains("blocking:"))
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.IO.Read.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = ISO_9945.Kernel.IO.Read.Error.handle(.invalid)
        #expect(error is ISO_9945.Kernel.IO.Read.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = ISO_9945.Kernel.IO.Read.Error.handle(.invalid)
        #expect(error is ISO_9945.Kernel.IO.Read.Error)
    }

    @Test
    func `Error is Equatable - same case same value`() {
        let a = ISO_9945.Kernel.IO.Read.Error.handle(.invalid)
        let b = ISO_9945.Kernel.IO.Read.Error.handle(.invalid)
        #expect(a == b)
    }

    @Test
    func `Error is Equatable - same case different value`() {
        let a = ISO_9945.Kernel.IO.Read.Error.handle(.invalid)
        let b = ISO_9945.Kernel.IO.Read.Error.handle(.limit(.process))
        #expect(a != b)
    }

    @Test
    func `Error is Equatable - different cases`() {
        let a = ISO_9945.Kernel.IO.Read.Error.handle(.invalid)
        let b = ISO_9945.Kernel.IO.Read.Error.blocking(.wouldBlock)
        #expect(a != b)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.IO.Read.Error.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let cases: [ISO_9945.Kernel.IO.Read.Error] = [
            .handle(.invalid),
            .blocking(.wouldBlock),
            .platform(Error_Primitives.Error(code: .posix(1))),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}

// MARK: - POSIX Error Mapping (Fold) Tests
//
// Per the ratified 3-case shape (.handle, .blocking, .platform — Path X
// Cycle 2 dropped the .io(Kernel.IO.Error) mapping; commit a5a5db4),
// init(code:) cascades handle -> blocking -> .platform only. Codes that
// used to route to the dedicated .io case now fold into .platform.

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.IO.Read.Error.Test.Unit {
    @Test
    func `broken-classed code (EPIPE) folds into platform`() {
        let error = ISO_9945.Kernel.IO.Read.Error(code: .posix(EPIPE))
        if case .platform = error {
            // Expected: EPIPE is not handle- or blocking-mapped, so it
            // cascades through to .platform under the ratified 3-case shape.
        } else {
            Issue.record("Expected .platform case for EPIPE")
        }
    }

    @Test
    func `reset-classed code (ECONNRESET) folds into platform`() {
        let error = ISO_9945.Kernel.IO.Read.Error(code: .posix(ECONNRESET))
        if case .platform = error {
            // Expected: ECONNRESET is not handle- or blocking-mapped, so it
            // cascades through to .platform under the ratified 3-case shape.
        } else {
            Issue.record("Expected .platform case for ECONNRESET")
        }
    }

    @Test
    func `hardware-classed code (EIO) folds into platform`() {
        let error = ISO_9945.Kernel.IO.Read.Error(code: .posix(EIO))
        if case .platform = error {
            // Expected: EIO is not handle- or blocking-mapped, so it
            // cascades through to .platform under the ratified 3-case shape.
        } else {
            Issue.record("Expected .platform case for EIO")
        }
    }
}
