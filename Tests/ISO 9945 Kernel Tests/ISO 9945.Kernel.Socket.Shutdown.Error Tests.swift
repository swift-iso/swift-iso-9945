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
import ISO_9945_Kernel


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
    func `handle case exists`() {
        let handleError = ISO_9945.Kernel.Descriptor.Validity.Error.invalid
        let error = ISO_9945.Kernel.Socket.Shutdown.Error.handle(handleError)
        if case .handle(let e) = error {
            #expect(e == handleError)
        } else {
            Issue.record("Expected .handle case")
        }
    }

    @Test
    func `io case exists`() {
        let ioError = ISO_9945.Kernel.IO.Error.broken
        let error = ISO_9945.Kernel.Socket.Shutdown.Error.io(ioError)
        if case .io(let e) = error {
            #expect(e == ioError)
        } else {
            Issue.record("Expected .io case")
        }
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
        let error: any Swift.Error = ISO_9945.Kernel.Socket.Shutdown.Error.handle(.invalid)
        #expect(error is ISO_9945.Kernel.Socket.Shutdown.Error)
    }

    @Test
    func `Error is Sendable`() {
        let value: any Sendable = ISO_9945.Kernel.Socket.Shutdown.Error.handle(.invalid)
        #expect(value is ISO_9945.Kernel.Socket.Shutdown.Error)
    }

    @Test
    func `Error is Equatable`() {
        let a = ISO_9945.Kernel.Socket.Shutdown.Error.handle(.invalid)
        let b = ISO_9945.Kernel.Socket.Shutdown.Error.handle(.invalid)
        let c = ISO_9945.Kernel.Socket.Shutdown.Error.io(.broken)
        #expect(a == b)
        #expect(a != c)
    }
}

// MARK: - Description Tests

extension ISO_9945.Kernel.Socket.Shutdown.Error.Test.Unit {
    @Test
    func `handle error description contains 'handle'`() {
        let error = ISO_9945.Kernel.Socket.Shutdown.Error.handle(.invalid)
        #expect(error.description.contains("handle"))
    }

    @Test
    func `io error description contains 'io'`() {
        let error = ISO_9945.Kernel.Socket.Shutdown.Error.io(.broken)
        #expect(error.description.contains("io"))
    }

    @Test
    func `platform error description`() {
        let platformError = Error_Primitives.Error(code: .posix(42))
        let error = ISO_9945.Kernel.Socket.Shutdown.Error.platform(platformError)
        #expect(!error.description.isEmpty)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.Socket.Shutdown.Error.Test.EdgeCase {
    @Test
    func `Different cases are not equal`() {
        let handleError = ISO_9945.Kernel.Socket.Shutdown.Error.handle(.invalid)
        let ioError = ISO_9945.Kernel.Socket.Shutdown.Error.io(.broken)
        let platformError = ISO_9945.Kernel.Socket.Shutdown.Error.platform(
            Error_Primitives.Error(code: .posix(1))
        )
        #expect(handleError != ioError)
        #expect(handleError != platformError)
        #expect(ioError != platformError)
    }

    @Test
    func `Same case with different values are not equal`() {
        let a = ISO_9945.Kernel.Socket.Shutdown.Error.io(.broken)
        let b = ISO_9945.Kernel.Socket.Shutdown.Error.io(.reset)
        #expect(a != b)
    }
}
