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
    func `io case stores IO.Error`() {
        let ioError = ISO_9945.Kernel.IO.Error.broken
        let error = ISO_9945.Kernel.IO.Read.Error.io(ioError)
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

    @Test
    func `io description format`() {
        let error = ISO_9945.Kernel.IO.Read.Error.io(.broken)
        #expect(error.description.contains("io:"))
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
        let a = ISO_9945.Kernel.IO.Read.Error.io(.broken)
        let b = ISO_9945.Kernel.IO.Read.Error.io(.broken)
        #expect(a == b)
    }

    @Test
    func `Error is Equatable - same case different value`() {
        let a = ISO_9945.Kernel.IO.Read.Error.io(.broken)
        let b = ISO_9945.Kernel.IO.Read.Error.io(.reset)
        #expect(a != b)
    }

    @Test
    func `Error is Equatable - different cases`() {
        let a = ISO_9945.Kernel.IO.Read.Error.handle(.invalid)
        let b = ISO_9945.Kernel.IO.Read.Error.io(.broken)
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
            .io(.broken),
            .platform(Error_Primitives.Error(code: .posix(1))),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }
}
