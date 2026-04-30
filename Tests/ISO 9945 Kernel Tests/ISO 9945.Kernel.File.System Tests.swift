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


extension Kernel.File.System {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.System.Test.Unit {
    @Test
    func `System namespace exists`() {
        _ = Kernel.File.System.self
    }

    @Test
    func `System is an enum`() {
        let _: Kernel.File.System.Type = Kernel.File.System.self
    }
}

// MARK: - Nested Types

extension Kernel.File.System.Test.Unit {
    @Test
    func `System.Kind type exists`() {
        let _: Kernel.File.System.Kind.Type = Kernel.File.System.Kind.self
    }

    @Test
    func `System.Stats type exists`() {
        let _: Kernel.File.System.Stats.Type = Kernel.File.System.Stats.self
    }

    @Test
    func `System.Block type exists`() {
        let _: Kernel.File.System.Block.Type = Kernel.File.System.Block.self
    }
}
