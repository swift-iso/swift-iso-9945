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


extension Kernel.IO.Read.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.IO.Read.Error.Test.Unit {
    @Test
    func `handle case stores Descriptor.Validity.Error`() {
        let validityError = Kernel.Descriptor.Validity.Error.invalid
        let error = Kernel.IO.Read.Error.handle(validityError)
        if case .handle(let stored) = error {
            #expect(stored == validityError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test
    func `blocking case stores IO.Blocking.Error`() {
        let blockingError = Kernel.IO.Blocking.Error.wouldBlock
        let error = Kernel.IO.Read.Error.blocking(blockingError)
        if case .blocking(let stored) = error {
            #expect(stored == blockingError)
        } else {
            Issue.record("Expected .blocking case")
        }
    }

    @Test
    func `io case stores IO.Error`() {
        let ioError = Kernel.IO.Error.broken
        let error = Kernel.IO.Read.Error.io(ioError)
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
        let error = Kernel.IO.Read.Error.platform(unmappedError)
        if case .platform(let stored) = error {
            #expect(stored == unmappedError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.IO.Read.Error.Test.Unit {
    @Test
    func `handle description format`() {
        let error = Kernel.IO.Read.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }

    @Test
    func `blocking description format`() {
        let error = Kernel.IO.Read.Error.blocking(.wouldBlock)
        #expect(error.description.contains("blocking:"))
    }

    @Test
    func `io description format`() {
        let error = Kernel.IO.Read.Error.io(.broken)
        #expect(error.description.contains("io:"))
    }

}

// MARK: - Conformance Tests

extension Kernel.IO.Read.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = Kernel.IO.Read.Error.handle(.invalid)
        #expect(error is Kernel.IO.Read.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = Kernel.IO.Read.Error.handle(.invalid)
        #expect(error is Kernel.IO.Read.Error)
    }

    @Test
    func `Error is Equatable - same case same value`() {
        let a = Kernel.IO.Read.Error.io(.broken)
        let b = Kernel.IO.Read.Error.io(.broken)
        #expect(a == b)
    }

    @Test
    func `Error is Equatable - same case different value`() {
        let a = Kernel.IO.Read.Error.io(.broken)
        let b = Kernel.IO.Read.Error.io(.reset)
        #expect(a != b)
    }

    @Test
    func `Error is Equatable - different cases`() {
        let a = Kernel.IO.Read.Error.handle(.invalid)
        let b = Kernel.IO.Read.Error.io(.broken)
        #expect(a != b)
    }
}

// MARK: - Edge Cases

extension Kernel.IO.Read.Error.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let cases: [Kernel.IO.Read.Error] = [
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
