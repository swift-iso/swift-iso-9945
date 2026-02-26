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
import ISO_9945_Kernel_Test_Support
import ISO_9945
import Kernel_Primitives

@testable import ISO_9945_Kernel

extension Kernel.Unlink {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Unlink.Test.Unit {
    @Test("Unlink namespace exists")
    func namespaceExists() {
        _ = Kernel.Unlink.self
    }

    @Test("Unlink is an enum")
    func isEnum() {
        let _: Kernel.Unlink.Type = Kernel.Unlink.self
    }
}

// MARK: - Nested Types

extension Kernel.Unlink.Test.Unit {
    @Test("Unlink.Error type exists")
    func errorTypeExists() {
        let _: Kernel.Unlink.Error.Type = Kernel.Unlink.Error.self
    }
}
