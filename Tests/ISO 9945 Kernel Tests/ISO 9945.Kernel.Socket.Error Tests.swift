// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Tests use Apple native Testing framework
import Testing
import Kernel_Primitives_Test_Support


extension Kernel.Socket.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Socket.Error.Test.Unit {
    @Test
    func `Error type exists`() {
        let _: Kernel.Socket.Error.Type = Kernel.Socket.Error.self
    }

    @Test
    func `handle case exists`() {
        let handleError = Kernel.Descriptor.Validity.Error.invalid
        let error = Kernel.Socket.Error.handle(handleError)
        if case .handle(let e) = error {
            #expect(e == handleError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test
    func `platform case exists`() {
        let platformError = Error_Primitives.Error(code: .posix(999))
        let error = Kernel.Socket.Error.platform(platformError)
        if case .platform(let e) = error {
            #expect(e == platformError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.Socket.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = Kernel.Socket.Error.handle(.invalid)
        #expect(error is Kernel.Socket.Error)
    }

    @Test
    func `Error is Sendable`() {
        let value: any Sendable = Kernel.Socket.Error.handle(.invalid)
        #expect(value is Kernel.Socket.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = Kernel.Socket.Error.handle(.invalid)
        let b = Kernel.Socket.Error.handle(.invalid)
        let c = Kernel.Socket.Error.platform(Error_Primitives.Error(code: .posix(1)))
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Description Tests

extension Kernel.Socket.Error.Test.Unit {
    @Test
    func `handle error description contains 'handle'`() {
        let error = Kernel.Socket.Error.handle(.invalid)
        #expect(error.description.contains("handle"))
    }

    @Test
    func `platform error description`() {
        let platformError = Error_Primitives.Error(code: .posix(42))
        let error = Kernel.Socket.Error.platform(platformError)
        #expect(!error.description.isEmpty)
    }
}

// MARK: - Edge Cases

extension Kernel.Socket.Error.Test.EdgeCase {
    @Test
    func `Different cases are not equal`() {
        let handleError = Kernel.Socket.Error.handle(.invalid)
        let platformError = Kernel.Socket.Error.platform(
            Error_Primitives.Error(code: .posix(1))
        )
        #expect(handleError != platformError)
    }
}
