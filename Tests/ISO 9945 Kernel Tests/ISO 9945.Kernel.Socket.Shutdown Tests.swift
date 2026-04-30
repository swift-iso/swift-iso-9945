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


extension Kernel.Socket.Shutdown {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Socket.Shutdown.Test.Unit {
    @Test
    func `Shutdown namespace exists`() {
        _ = Kernel.Socket.Shutdown.self
    }

    @Test
    func `Shutdown is an enum`() {
        let _: Kernel.Socket.Shutdown.Type = Kernel.Socket.Shutdown.self
    }
}

// MARK: - Nested Types

extension Kernel.Socket.Shutdown.Test.Unit {
    @Test
    func `Shutdown.How type exists`() {
        let _: Kernel.Socket.Shutdown.How.Type = Kernel.Socket.Shutdown.How.self
    }

    @Test
    func `Shutdown.Error type exists`() {
        let _: Kernel.Socket.Shutdown.Error.Type = Kernel.Socket.Shutdown.Error.self
    }
}
