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
import Tagged_Primitives_Standard_Library_Integration
import ISO_9945_Kernel


extension ISO_9945.Kernel.Socket {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Socket.Test.Unit {
    @Test
    func `Socket namespace exists`() {
        _ = ISO_9945.Kernel.Socket.self
    }

    @Test
    func `Socket is an enum`() {
        let _: ISO_9945.Kernel.Socket.Type = ISO_9945.Kernel.Socket.self
    }
}

// MARK: - Nested Types

extension ISO_9945.Kernel.Socket.Test.Unit {
    @Test
    func `Socket.Descriptor type exists`() {
        let _: ISO_9945.Kernel.Socket.Descriptor.Type = ISO_9945.Kernel.Socket.Descriptor.self
    }

    @Test
    func `Socket.Error type exists`() {
        let _: ISO_9945.Kernel.Socket.Error.Type = ISO_9945.Kernel.Socket.Error.self
    }

    @Test
    func `Socket.Backlog type exists`() {
        let _: ISO_9945.Kernel.Socket.Backlog.Type = ISO_9945.Kernel.Socket.Backlog.self
    }

    @Test
    func `Socket.Shutdown type exists`() {
        let _: ISO_9945.Kernel.Socket.Shutdown.Type = ISO_9945.Kernel.Socket.Shutdown.self
    }

    #if !os(Windows)
        @Test
        func `Socket.Options type exists`() {
            let _: ISO_9945.Kernel.Socket.Options.Type = ISO_9945.Kernel.Socket.Options.self
        }
    #endif
}
