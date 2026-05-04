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


extension ISO_9945.Kernel.IO.Blocking {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.IO.Blocking.Test.Unit {
    @Test
    func `Blocking namespace exists`() {
        // ISO_9945.Kernel.IO.Blocking is a public enum namespace
        _ = ISO_9945.Kernel.IO.Blocking.self
    }

    @Test
    func `Blocking is an enum`() {
        let _: ISO_9945.Kernel.IO.Blocking.Type = ISO_9945.Kernel.IO.Blocking.self
    }

    @Test
    func `Blocking is Sendable`() {
        let _: any Sendable.Type = ISO_9945.Kernel.IO.Blocking.self
    }
}

// MARK: - Nested Types

extension ISO_9945.Kernel.IO.Blocking.Test.Unit {
    @Test
    func `Blocking.Error type exists`() {
        let _: ISO_9945.Kernel.IO.Blocking.Error.Type = ISO_9945.Kernel.IO.Blocking.Error.self
    }
}
