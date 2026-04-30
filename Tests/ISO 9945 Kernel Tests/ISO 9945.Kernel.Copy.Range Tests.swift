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

#if os(Linux)
    // Tests use Apple native Testing framework
import Testing
import Kernel_Primitives_Test_Support


    extension Kernel.Copy.Range {
        @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
    }

    // MARK: - Unit Tests

    extension Kernel.Copy.Range.Test.Unit {
        @Test
        func `Range namespace exists`() {
            // Kernel.Copy.Range is a public enum namespace (Linux only)
            _ = Kernel.Copy.Range.self
        }

        @Test
        func `Range is an enum`() {
            let _: Kernel.Copy.Range.Type = Kernel.Copy.Range.self
        }

        // NOTE: Kernel.Copy.Range.copy() is defined at L2 (swift-iso-9945).
        // Signature verification belongs in ISO 9945 Kernel tests.
    }
