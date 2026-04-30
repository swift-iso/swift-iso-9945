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


extension Kernel.File.Stats.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.Stats.Error.Test.Unit {
    @Test
    func `handle case stores Descriptor.Validity.Error`() {
        let handleError = Kernel.Descriptor.Validity.Error.invalid
        let error = Kernel.File.Stats.Error.handle(handleError)
        if case .handle(let stored) = error {
            #expect(stored == handleError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test
    func `io case stores IO.Error`() {
        let ioError = Kernel.IO.Error.hardware
        let error = Kernel.File.Stats.Error.io(ioError)
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
        let error = Kernel.File.Stats.Error.platform(unmappedError)
        if case .platform(let stored) = error {
            #expect(stored == unmappedError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Description Tests

extension Kernel.File.Stats.Error.Test.Unit {
    @Test
    func `handle description format`() {
        let error = Kernel.File.Stats.Error.handle(.invalid)
        #expect(error.description.contains("handle:"))
    }

    @Test
    func `io description format`() {
        let error = Kernel.File.Stats.Error.io(.hardware)
        #expect(error.description.contains("io:"))
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Stats.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = Kernel.File.Stats.Error.handle(.invalid)
        #expect(error is Kernel.File.Stats.Error)
    }

    @Test
    func `Error is Sendable`() {
        let error: any Sendable = Kernel.File.Stats.Error.handle(.invalid)
        #expect(error is Kernel.File.Stats.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = Kernel.File.Stats.Error.handle(.invalid)
        let b = Kernel.File.Stats.Error.handle(.invalid)
        let c = Kernel.File.Stats.Error.io(.hardware)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Stats.Error.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let cases: [Kernel.File.Stats.Error] = [
            .handle(.invalid),
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
    func `handle invalid vs limit are distinct`() {
        let invalid = Kernel.File.Stats.Error.handle(.invalid)
        let processLimit = Kernel.File.Stats.Error.handle(.limit(.process))
        let systemLimit = Kernel.File.Stats.Error.handle(.limit(.system))
        #expect(invalid != processLimit)
        #expect(processLimit != systemLimit)
    }

    @Test
    func `different io errors are distinct`() {
        let hardware = Kernel.File.Stats.Error.io(.hardware)
        let broken = Kernel.File.Stats.Error.io(.broken)
        #expect(hardware != broken)
    }
}
