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

@testable import Kernel_File_Primitives

extension Kernel.Storage {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Storage.Test.Unit {
    @Test
    func `Storage namespace exists`() {
        _ = Kernel.Storage.self
    }

    @Test
    func `Storage is an enum`() {
        let _: Kernel.Storage.Type = Kernel.Storage.self
    }
}

// MARK: - Nested Types

extension Kernel.Storage.Test.Unit {
    @Test
    func `Storage.Error type exists`() {
        let _: Kernel.Storage.Error.Type = Kernel.Storage.Error.self
    }
}
