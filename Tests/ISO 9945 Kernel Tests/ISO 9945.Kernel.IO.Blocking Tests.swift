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


extension Kernel.IO.Blocking {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.IO.Blocking.Test.Unit {
    @Test
    func `Blocking namespace exists`() {
        // Kernel.IO.Blocking is a public enum namespace
        _ = Kernel.IO.Blocking.self
    }

    @Test
    func `Blocking is an enum`() {
        let _: Kernel.IO.Blocking.Type = Kernel.IO.Blocking.self
    }

    @Test
    func `Blocking is Sendable`() {
        let _: any Sendable.Type = Kernel.IO.Blocking.self
    }
}

// MARK: - Nested Types

extension Kernel.IO.Blocking.Test.Unit {
    @Test
    func `Blocking.Error type exists`() {
        let _: Kernel.IO.Blocking.Error.Type = Kernel.IO.Blocking.Error.self
    }
}
