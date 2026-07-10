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

import ISO_9945_Kernel
import Tagged_Primitives_Standard_Library_Integration
// Tests use Apple native Testing framework
import Testing

extension ISO_9945.Kernel.Socket.Shutdown.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Socket.Shutdown.Error.Test.Unit {
    @Test
    func `Error type exists`() {
        let _: ISO_9945.Kernel.Socket.Shutdown.Error.Type = ISO_9945.Kernel.Socket.Shutdown.Error.self
    }

    @Test
    func `platform case exists`() {
        let platformError = Error_Primitives.Error(code: .posix(999))
        let error = ISO_9945.Kernel.Socket.Shutdown.Error.platform(platformError)
        if case .platform(let e) = error {
            #expect(e == platformError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.Socket.Shutdown.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = ISO_9945.Kernel.Socket.Shutdown.Error.platform(
            Error_Primitives.Error(code: .posix(1))
        )
        #expect(error is ISO_9945.Kernel.Socket.Shutdown.Error)
    }

    @Test
    func `Error is Sendable`() {
        let value: any Sendable = ISO_9945.Kernel.Socket.Shutdown.Error.platform(
            Error_Primitives.Error(code: .posix(1))
        )
        #expect(value is ISO_9945.Kernel.Socket.Shutdown.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = ISO_9945.Kernel.Socket.Shutdown.Error.platform(Error_Primitives.Error(code: .posix(1)))
        let b = ISO_9945.Kernel.Socket.Shutdown.Error.platform(Error_Primitives.Error(code: .posix(1)))
        let c = ISO_9945.Kernel.Socket.Shutdown.Error.platform(Error_Primitives.Error(code: .posix(2)))
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Description Tests

extension ISO_9945.Kernel.Socket.Shutdown.Error.Test.Unit {
    @Test
    func `platform error description`() {
        let platformError = Error_Primitives.Error(code: .posix(42))
        let error = ISO_9945.Kernel.Socket.Shutdown.Error.platform(platformError)
        #expect(!error.description.isEmpty)
    }
}

// MARK: - Edge Cases
//
// Per the ratified 1-case shape (.platform only — Path X Cycle 2 dropped the
// .io(Kernel.IO.Error) mapping; commit a5a5db4), Socket.Shutdown.Error carries
// no domain-specific cases anymore, so there is no cross-case comparison left
// to exercise; only same-case/different-value distinctness applies.

extension ISO_9945.Kernel.Socket.Shutdown.Error.Test.EdgeCase {
    @Test
    func `Same case with different values are not equal`() {
        let a = ISO_9945.Kernel.Socket.Shutdown.Error.platform(Error_Primitives.Error(code: .posix(1)))
        let b = ISO_9945.Kernel.Socket.Shutdown.Error.platform(Error_Primitives.Error(code: .posix(2)))
        #expect(a != b)
    }
}
