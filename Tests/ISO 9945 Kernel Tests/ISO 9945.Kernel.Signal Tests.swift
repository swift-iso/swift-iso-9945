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

import Kernel_Primitives_Core
import Kernel_File_Primitives
import Path_Primitives
import Error_Primitives
import Testing

@testable import ISO_9945_Kernel

extension Kernel.Signal {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension Kernel.Signal.Test.Unit {
    @Test
    func `Signal namespace exists`() {
        _ = Kernel.Signal.self
    }

    @Test
    func `Signal is an enum`() {
        let _: Kernel.Signal.Type = Kernel.Signal.self
    }
}

// MARK: - Nested Types

extension Kernel.Signal.Test.Unit {
    #if canImport(Darwin) || canImport(Glibc) || canImport(Musl)
        @Test
        func `Signal.Error type exists`() {
            let _: Kernel.Signal.Error.Type = Kernel.Signal.Error.self
        }
    #endif
}
