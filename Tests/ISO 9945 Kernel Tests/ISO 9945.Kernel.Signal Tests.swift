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

import Path_Primitives
import Error_Primitives
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Signal {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Signal.Test.Unit {
    @Test
    func `Signal namespace exists`() {
        _ = ISO_9945.Kernel.Signal.self
    }

    @Test
    func `Signal is an enum`() {
        let _: ISO_9945.Kernel.Signal.Type = ISO_9945.Kernel.Signal.self
    }
}

// MARK: - Nested Types

extension ISO_9945.Kernel.Signal.Test.Unit {
    #if canImport(Darwin) || canImport(Glibc) || canImport(Musl)
        @Test
        func `Signal.Error type exists`() {
            let _: ISO_9945.Kernel.Signal.Error.Type = ISO_9945.Kernel.Signal.Error.self
        }
    #endif
}
