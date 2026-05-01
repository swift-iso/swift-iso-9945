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
import ISO_9945_Kernel


extension ISO_9945.Kernel.Storage {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Storage.Test.Unit {
    @Test
    func `Storage namespace exists`() {
        _ = ISO_9945.Kernel.Storage.self
    }

    @Test
    func `Storage is an enum`() {
        let _: ISO_9945.Kernel.Storage.Type = ISO_9945.Kernel.Storage.self
    }
}

// MARK: - Nested Types

extension ISO_9945.Kernel.Storage.Test.Unit {
    @Test
    func `Storage.Error type exists`() {
        let _: ISO_9945.Kernel.Storage.Error.Type = ISO_9945.Kernel.Storage.Error.self
    }
}
