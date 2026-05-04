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
import Tagged_Primitives_Standard_Library_Integration
import ISO_9945_Kernel


extension ISO_9945.Kernel.File.Clone {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.Clone.Test.Unit {
    @Test
    func `Clone namespace exists`() {
        _ = ISO_9945.Kernel.File.Clone.self
    }

    @Test
    func `Clone is an enum`() {
        let _: ISO_9945.Kernel.File.Clone.Type = ISO_9945.Kernel.File.Clone.self
    }
}

// MARK: - Nested Types

extension ISO_9945.Kernel.File.Clone.Test.Unit {
    @Test
    func `Clone.Capability type exists`() {
        let _: ISO_9945.Kernel.File.Clone.Capability.Type = ISO_9945.Kernel.File.Clone.Capability.self
    }

    @Test
    func `Clone.Behavior type exists`() {
        let _: ISO_9945.Kernel.File.Clone.Behavior.Type = ISO_9945.Kernel.File.Clone.Behavior.self
    }

    @Test
    func `Clone.Error type exists`() {
        let _: ISO_9945.Kernel.File.Clone.Error.Type = ISO_9945.Kernel.File.Clone.Error.self
    }

    @Test
    func `Clone.Result type exists`() {
        let _: ISO_9945.Kernel.File.Clone.Result.Type = ISO_9945.Kernel.File.Clone.Result.self
    }
}
