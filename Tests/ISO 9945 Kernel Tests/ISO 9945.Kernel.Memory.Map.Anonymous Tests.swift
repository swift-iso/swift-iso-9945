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

import Error_Primitives
import ISO_9945_Kernel_Test_Support
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
// Tests use Apple native Testing framework
import Testing

@testable import ISO_9945_Kernel

extension Memory.Map.Anonymous {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Memory.Map.Anonymous.Test.Unit {
    @Test
    func `Anonymous namespace exists`() {
        _ = Memory.Map.Anonymous.self
    }

    @Test
    func `Anonymous is an enum`() {
        let _: Memory.Map.Anonymous.Type = Memory.Map.Anonymous.self
    }
}

// MARK: - Functional Tests

extension Memory.Map.Anonymous.Test.Unit {
    @Test
    func `map creates a valid region`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        // Memory.Address is non-null by construction (Tagged<Memory, Ordinal>);
        // assert the bit pattern is non-zero as the observable equivalent.
        #expect(region.base.bitPattern != 0)
        #expect(region.length == pageSize)
    }

    @Test
    func `map with custom protection`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(
            length: pageSize,
            protection: .read
        )
        defer { try? Memory.Map.unmap(region) }

        // Memory.Address is non-null by construction (Tagged<Memory, Ordinal>);
        // assert the bit pattern is non-zero as the observable equivalent.
        #expect(region.base.bitPattern != 0)
    }

    @Test
    func `map private by default`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        // Should succeed (private is default)
        // Memory.Address is non-null by construction (Tagged<Memory, Ordinal>);
        // assert the bit pattern is non-zero as the observable equivalent.
        #expect(region.base.bitPattern != 0)
    }

    @Test
    func `map shared when specified`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(
            length: pageSize,
            shared: true
        )
        defer { try? Memory.Map.unmap(region) }

        // Memory.Address is non-null by construction (Tagged<Memory, Ordinal>);
        // assert the bit pattern is non-zero as the observable equivalent.
        #expect(region.base.bitPattern != 0)
    }
}

// MARK: - Windows Tests

#if os(Windows)
    extension Memory.Map.Anonymous.Test.Unit {
        @Test
        func `map creates a valid region on Windows`() throws {
            let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
            let region = try Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Memory.Map.unmap(region) }

            #expect(region.base != nil)
            #expect(region.length == pageSize)
        }
    }
#endif
