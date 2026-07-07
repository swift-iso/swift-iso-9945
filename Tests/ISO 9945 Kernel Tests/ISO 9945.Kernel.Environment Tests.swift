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

import Error_Primitives
import ISO_9945_Kernel_Test_Support
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
// Tests use Apple native Testing framework
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Environment {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Environment.Test.Unit {
    @Test
    func `Environment namespace exists`() {
        _ = ISO_9945.Kernel.Environment.self
    }

    @Test
    func `Environment is an enum`() {
        let _: ISO_9945.Kernel.Environment.Type = ISO_9945.Kernel.Environment.self
    }
}

// MARK: - Get Tests

extension ISO_9945.Kernel.Environment.Test.Unit {
    @Test
    func `get returns nil for unset variable`() {
        let result = ISO_9945.Kernel.Environment.get("__KERNEL_TEST_UNSET_VAR_12345__")
        // String is ~Copyable, so we check nil-ness differently
        let isNil = (result == nil)
        #expect(isNil)
    }

    @Test
    func `get returns value for PATH`() {
        // PATH should always be set on all platforms
        let result = ISO_9945.Kernel.Environment.get("PATH")
        // String is ~Copyable, so we check nil-ness differently
        let isNotNil = (result != nil)
        #expect(isNotNil)
    }
}

// MARK: - isSet Tests
// NOTE: isSet API not yet implemented in ISO_9945.Kernel.Environment
// These tests are disabled until the API is added.

// extension ISO_9945.Kernel.Environment.Test.Unit {
//    @Test("isSet returns false for unset variable")
//    func isSetUnsetVariable() {
//        let result = ISO_9945.Kernel.Environment.isSet("__KERNEL_TEST_UNSET_VAR_12345__")
//        #expect(result == false)
//    }
//
//    @Test("isSet returns true for PATH")
//    func isSetPathVariable() {
//        let result = ISO_9945.Kernel.Environment.isSet("PATH")
//        #expect(result == true)
//    }
//
//    @Test("isSet with value checks exact match")
//    func isSetWithValue() {
//        // Test with a non-existent value
//        let result = ISO_9945.Kernel.Environment.isSet("PATH", to: "__IMPOSSIBLE_VALUE__")
//        #expect(result == false)
//    }
// }
