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
import ISO_9945_Kernel


extension ISO_9945.Kernel.File.System {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.System.Test.Unit {
    @Test
    func `System namespace exists`() {
        _ = ISO_9945.Kernel.File.System.self
    }

    @Test
    func `System is an enum`() {
        let _: ISO_9945.Kernel.File.System.Type = ISO_9945.Kernel.File.System.self
    }
}

// MARK: - Nested Types

extension ISO_9945.Kernel.File.System.Test.Unit {
    @Test
    func `System.Kind type exists`() {
        let _: ISO_9945.Kernel.File.System.Kind.Type = ISO_9945.Kernel.File.System.Kind.self
    }

    @Test
    func `System.Stats type exists`() {
        let _: ISO_9945.Kernel.File.System.Stats.Type = ISO_9945.Kernel.File.System.Stats.self
    }

    @Test
    func `System.Block type exists`() {
        let _: ISO_9945.Kernel.File.System.Block.Type = ISO_9945.Kernel.File.System.Block.self
    }
}
