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


extension Kernel.Socket {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Socket.Test.Unit {
    @Test
    func `Socket namespace exists`() {
        _ = Kernel.Socket.self
    }

    @Test
    func `Socket is an enum`() {
        let _: Kernel.Socket.Type = Kernel.Socket.self
    }
}

// MARK: - Nested Types

extension Kernel.Socket.Test.Unit {
    @Test
    func `Socket.Descriptor type exists`() {
        let _: Kernel.Socket.Descriptor.Type = Kernel.Socket.Descriptor.self
    }

    @Test
    func `Socket.Error type exists`() {
        let _: Kernel.Socket.Error.Type = Kernel.Socket.Error.self
    }

    @Test
    func `Socket.Backlog type exists`() {
        let _: Kernel.Socket.Backlog.Type = Kernel.Socket.Backlog.self
    }

    @Test
    func `Socket.Shutdown type exists`() {
        let _: Kernel.Socket.Shutdown.Type = Kernel.Socket.Shutdown.self
    }

    #if !os(Windows)
        @Test
        func `Socket.Options type exists`() {
            let _: Kernel.Socket.Options.Type = Kernel.Socket.Options.self
        }
    #endif
}
