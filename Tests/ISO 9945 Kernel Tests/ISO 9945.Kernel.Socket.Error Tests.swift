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

extension ISO_9945.Kernel.Socket.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Socket.Error.Test.Unit {
    @Test
    func `Error type exists`() {
        let _: ISO_9945.Kernel.Socket.Error.Type = ISO_9945.Kernel.Socket.Error.self
    }

    @Test
    func `platform case exists`() {
        let platformError = Error_Primitives.Error(code: .posix(999))
        let error = ISO_9945.Kernel.Socket.Error.platform(platformError)
        if case .platform(let e) = error {
            #expect(e == platformError)
        } else {
            Issue.record("Expected .platform case")
        }
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.Socket.Error.Test.Unit {
    @Test
    func `Error conforms to Swift.Error`() {
        let error: any Swift.Error = ISO_9945.Kernel.Socket.Error.platform(
            Error_Primitives.Error(code: .posix(1))
        )
        #expect(error is ISO_9945.Kernel.Socket.Error)
    }

    @Test
    func `Error is Sendable`() {
        let value: any Sendable = ISO_9945.Kernel.Socket.Error.platform(
            Error_Primitives.Error(code: .posix(1))
        )
        #expect(value is ISO_9945.Kernel.Socket.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = ISO_9945.Kernel.Socket.Error.platform(Error_Primitives.Error(code: .posix(1)))
        let b = ISO_9945.Kernel.Socket.Error.platform(Error_Primitives.Error(code: .posix(1)))
        let c = ISO_9945.Kernel.Socket.Error.platform(Error_Primitives.Error(code: .posix(2)))
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Description Tests

extension ISO_9945.Kernel.Socket.Error.Test.Unit {
    @Test
    func `platform error description`() {
        let platformError = Error_Primitives.Error(code: .posix(42))
        let error = ISO_9945.Kernel.Socket.Error.platform(platformError)
        #expect(!error.description.isEmpty)
    }
}

// MARK: - Edge Cases
//
// Per commit 29a7a63 (Path X Cycle 21 — Socket: absorb L1 Socket vocab into
// L2), the '.handle(Kernel.Descriptor.Validity.Error)' case was dropped from
// both Socket.Error and Socket.Shutdown.Error per the L1-domain-only /
// L3-composes principle, leaving the ratified 1-case shape (.platform only).
// With no second case left, there is no cross-case comparison to exercise;
// only same-case/different-value distinctness applies.

extension ISO_9945.Kernel.Socket.Error.Test.EdgeCase {
    @Test
    func `Same case with different values are not equal`() {
        let a = ISO_9945.Kernel.Socket.Error.platform(Error_Primitives.Error(code: .posix(1)))
        let b = ISO_9945.Kernel.Socket.Error.platform(Error_Primitives.Error(code: .posix(2)))
        #expect(a != b)
    }
}
