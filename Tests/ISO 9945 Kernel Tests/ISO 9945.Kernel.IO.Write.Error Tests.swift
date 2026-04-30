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

@testable import Kernel_File_Primitives

extension Kernel.IO.Write.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.IO.Write.Error.Test.Unit {
    @Test
    func `handle case stores Descriptor.Validity.Error`() {
        let validityError = Kernel.Descriptor.Validity.Error.invalid
        let error = Kernel.IO.Write.Error.handle(validityError)
        if case .handle(let stored) = error {
            #expect(stored == validityError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test
    func `blocking case stores IO.Blocking.Error`() {
        let blockingError = Kernel.IO.Blocking.Error.wouldBlock
        let error = Kernel.IO.Write.Error.blocking(blockingError)
        if case .blocking(let stored) = error {
            #expect(stored == blockingError)
        } else {
            Issue.record("Expected .blocking case")
        }
    }

    @Test
    func `io case stores IO.Error`() {
        let ioError = Kernel.IO.Error.broken
        let error = Kernel.IO.Write.Error.io(ioError)
        if case .io(let stored) = error {
            #expect(stored == ioError)
        } else {
            Issue.record("Expected .io case")
        }
    }

    @Test
    func `space case stores Storage.Error`() {
        let spaceError = Kernel.Storage.Error.exhausted
        let error = Kernel.IO.Write.Error.space(spaceError)
        if case .space(let stored) = error {
            #expect(stored == spaceError)
        } else {
            Issue.record("Expected .space case")
        }
    }

    @Test
    func `platform case stores Error_Primitives.Error`() {
        let code = Error_Primitives.Error.Code.posix(999)
        let unmappedError = Error_Primitives.Error(code: code)
        let error = Kernel.IO.Write.Error.platform(unmappedError)
        if case .platform(let stored) = error {
            #expect(stored == unmappedError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.IO.Write.Error.Test.Unit {
    @Test
    func `handle description format`() {
        let error = Kernel.IO.Write.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }

    @Test
    func `blocking description format`() {
        let error = Kernel.IO.Write.Error.blocking(.wouldBlock)
        #expect(error.description.contains("blocking:"))
    }

    @Test
    func `io description format`() {
        let error = Kernel.IO.Write.Error.io(.broken)
        #expect(error.description.contains("io:"))
    }

    @Test
    func `space description format`() {
        let error = Kernel.IO.Write.Error.space(.exhausted)
        #expect(error.description.contains("space:"))
    }

}

// MARK: - Conformance Tests

extension Kernel.IO.Write.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = Kernel.IO.Write.Error.handle(.invalid)
        #expect(error is Kernel.IO.Write.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = Kernel.IO.Write.Error.handle(.invalid)
        #expect(error is Kernel.IO.Write.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = Kernel.IO.Write.Error.space(.exhausted)
        let b = Kernel.IO.Write.Error.space(.exhausted)
        let c = Kernel.IO.Write.Error.space(.quota)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension Kernel.IO.Write.Error.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let cases: [Kernel.IO.Write.Error] = [
            .handle(.invalid),
            .blocking(.wouldBlock),
            .io(.broken),
            .space(.exhausted),
            .platform(Error_Primitives.Error(code: .posix(1))),
        ]

        for i in 0..<cases.count {
            for j in (i + 1)..<cases.count {
                #expect(cases[i] != cases[j])
            }
        }
    }

    @Test
    func `space exhausted vs quota`() {
        let exhausted = Kernel.IO.Write.Error.space(.exhausted)
        let quota = Kernel.IO.Write.Error.space(.quota)
        #expect(exhausted != quota)
    }

    @Test
    func `Write has space case that Read lacks`() {
        // Verify the space case exists (unique to Write.Error vs Read.Error)
        let error = Kernel.IO.Write.Error.space(.exhausted)
        if case .space = error {
            // Expected - this case exists
        } else {
            Issue.record("Expected .space case")
        }
    }
}
