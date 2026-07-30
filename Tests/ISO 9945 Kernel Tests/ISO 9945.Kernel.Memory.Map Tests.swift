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

import Error_Primitives
import ISO_9945_Kernel_Test_Support
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
// Tests use Apple native Testing framework
import Testing

@testable import ISO_9945_Kernel

extension Memory.Map {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Map Tests

extension Memory.Map.Test.Unit {
    @Test
    func `anonymous map succeeds`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        // Memory.Address is non-null by construction (Tagged<Memory, Ordinal>);
        // assert the bit pattern is non-zero as the observable equivalent.
        #expect(region.base.bitPattern != 0)
        #expect(region.length == pageSize)
    }

    @Test
    func `map and unmap cycle works`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)

        // Unmap should succeed
        try Memory.Map.unmap(region)

        // Note: Accessing the memory after unmap is undefined behavior,
        // so we can't easily verify the unmap worked other than no error.
    }

    @Test
    func `mapped memory is readable and writable`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(
            length: pageSize,
            protection: .readWrite
        )
        defer { try? Memory.Map.unmap(region) }

        // Write to the mapped memory through the region's raw pointer.
        //
        // `Region` deliberately exposes no `span` / `mutableSpan` (upstream
        // swift-memory-map-primitives `fa6ccff`): it is a plain Copyable value
        // (base + length) carrying no lifetime relationship to the mapping's
        // liveness, so a byte view taken from it could outlive `munmap` and
        // silently dangle. Safe zero-copy access lives only on the ~Copyable
        // `Memory.Map` envelope, whose `@_lifetime(borrow self)` is anchored to
        // the owner. For a bare `Region` the honest surface is an explicitly
        // unsafe pointer access — the pattern `Anonymous.map(_:)`'s own doc
        // comment prescribes.
        unsafe region.base.mutablePointer.storeBytes(of: UInt8(42), toByteOffset: 0, as: UInt8.self)
        unsafe region.base.mutablePointer.storeBytes(of: UInt8(123), toByteOffset: 1, as: UInt8.self)

        // Read back through the read-only pointer.
        #expect(unsafe region.base.pointer.load(fromByteOffset: 0, as: UInt8.self) == 42)
        #expect(unsafe region.base.pointer.load(fromByteOffset: 1, as: UInt8.self) == 123)
    }

    @Test
    func `sync succeeds on mapped region`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        // Sync should succeed (even for anonymous, it's a no-op but shouldn't error)
        try Memory.Map.sync(addr: region.base, length: region.length)
    }

    @Test
    func `protect changes memory protection`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(
            length: pageSize,
            protection: .readWrite
        )
        defer { try? Memory.Map.unmap(region) }

        // Write some data first (see `mapped memory is readable and writable`
        // for why a bare `Region` uses an explicitly unsafe pointer access).
        unsafe region.base.mutablePointer.storeBytes(of: UInt8(99), toByteOffset: 0, as: UInt8.self)

        // Change to read-only (should succeed)
        try Memory.Map.protect(
            addr: region.base,
            length: region.length,
            protection: .read
        )

        // Reading should still work
        #expect(unsafe region.base.pointer.load(fromByteOffset: 0, as: UInt8.self) == 99)

        // Note: Writing would now cause SIGBUS/SIGSEGV, which we can't test safely
    }

    @Test
    func `advise does not throw`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        // advise is advisory-only and shouldn't throw
        Memory.Map.advise(
            addr: region.base,
            length: region.length,
            advice: .normal
        )
    }

    @Test
    func `multi-page mapping works`() throws {
        let multiPageSize = Memory.Address.Count(4 * UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: multiPageSize)
        defer { try? Memory.Map.unmap(region) }

        #expect(region.length == multiPageSize)

        // Write to first and last page (see `mapped memory is readable and
        // writable` for why a bare `Region` uses an unsafe pointer access).
        let lastOffset = Int(bitPattern: region.length) - 1
        unsafe region.base.mutablePointer.storeBytes(of: UInt8(1), toByteOffset: 0, as: UInt8.self)
        unsafe region.base.mutablePointer.storeBytes(of: UInt8(255), toByteOffset: lastOffset, as: UInt8.self)

        #expect(unsafe region.base.pointer.load(fromByteOffset: 0, as: UInt8.self) == 1)
        #expect(unsafe region.base.pointer.load(fromByteOffset: lastOffset, as: UInt8.self) == 255)
    }

    @Test
    func `Region struct stores base and length`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        // Verify region fields
        // Memory.Address is non-null by construction (Tagged<Memory, Ordinal>);
        // assert the bit pattern is non-zero as the observable equivalent.
        #expect(region.base.bitPattern != 0)
        #expect(region.length == pageSize)
    }
}

// MARK: - Error Tests

extension Memory.Map.Test.EdgeCase {
    @Test
    func `map with zero length throws`() {
        #expect(throws: Memory.Map.Error.self) {
            _ = try Memory.Map.Anonymous.map(length: .zero)
        }
    }

    @Test
    func `map with zero length throws invalid length error`() {
        do {
            _ = try Memory.Map.Anonymous.map(length: .zero)
            Issue.record("Expected error to be thrown")
        } catch {
            if case .invalid(.length) = error {
                // Expected
            } else {
                Issue.record("Expected .invalid(.length), got \(error)")
            }
        }
    }
}
