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


extension ISO_9945.Kernel.Socket.Shutdown {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Socket.Shutdown.Test.Unit {
    @Test
    func `Shutdown namespace exists`() {
        _ = ISO_9945.Kernel.Socket.Shutdown.self
    }

    @Test
    func `Shutdown is an enum`() {
        let _: ISO_9945.Kernel.Socket.Shutdown.Type = ISO_9945.Kernel.Socket.Shutdown.self
    }
}

// MARK: - Nested Types

extension ISO_9945.Kernel.Socket.Shutdown.Test.Unit {
    @Test
    func `Shutdown.How type exists`() {
        let _: ISO_9945.Kernel.Socket.Shutdown.How.Type = ISO_9945.Kernel.Socket.Shutdown.How.self
    }

    @Test
    func `Shutdown.Error type exists`() {
        let _: ISO_9945.Kernel.Socket.Shutdown.Error.Type = ISO_9945.Kernel.Socket.Shutdown.Error.self
    }
}
