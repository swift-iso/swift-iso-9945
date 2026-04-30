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


extension Kernel.File.Clone {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.Clone.Test.Unit {
    @Test
    func `Clone namespace exists`() {
        _ = Kernel.File.Clone.self
    }

    @Test
    func `Clone is an enum`() {
        let _: Kernel.File.Clone.Type = Kernel.File.Clone.self
    }
}

// MARK: - Nested Types

extension Kernel.File.Clone.Test.Unit {
    @Test
    func `Clone.Capability type exists`() {
        let _: Kernel.File.Clone.Capability.Type = Kernel.File.Clone.Capability.self
    }

    @Test
    func `Clone.Behavior type exists`() {
        let _: Kernel.File.Clone.Behavior.Type = Kernel.File.Clone.Behavior.self
    }

    @Test
    func `Clone.Error type exists`() {
        let _: Kernel.File.Clone.Error.Type = Kernel.File.Clone.Error.self
    }

    @Test
    func `Clone.Result type exists`() {
        let _: Kernel.File.Clone.Result.Type = Kernel.File.Clone.Result.self
    }
}
