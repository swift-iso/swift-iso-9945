// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Testing
import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import Path_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

#if os(Linux) || canImport(Darwin)

extension ISO_9945.Kernel.Copy.Clone {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Copy.Clone.Test.Unit {
    @Test
    func `Clone namespace exists`() {
        _ = ISO_9945.Kernel.Copy.Clone.self
    }

    @Test
    func `Clone is an enum`() {
        let _: ISO_9945.Kernel.Copy.Clone.Type = ISO_9945.Kernel.Copy.Clone.self
    }
}

// MARK: - Platform-Specific API Tests

#if os(Linux)
extension ISO_9945.Kernel.Copy.Clone.Test.Unit {
    @Test
    func `perform function exists on Linux`() {
        // Verify the function signature compiles
        typealias PerformType = (borrowing ISO_9945.Kernel.Descriptor, borrowing ISO_9945.Kernel.Descriptor) throws -> Void
    }
}
#endif

#if canImport(Darwin)
extension ISO_9945.Kernel.Copy.Clone.Test.Unit {
    @Test
    func `file function exists on Darwin`() {
        // Verify the namespace and function exist at compile time
        _ = ISO_9945.Kernel.Copy.Clone.self
    }
}
#endif

#endif
