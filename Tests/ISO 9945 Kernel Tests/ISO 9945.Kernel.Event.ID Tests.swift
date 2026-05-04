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

import Testing
import Tagged_Primitives_Standard_Library_Integration
import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
@_spi(Syscall) import Path_Primitives
@_spi(Syscall) import Error_Primitives

@testable import ISO_9945_Kernel

// ISO_9945.Kernel.Event.ID is a typealias to Tagged<ISO_9945.Kernel.Event, UInt>
// Test struct pattern cannot be used on typealiases

@Suite("ISO_9945.Kernel.Event.ID Tests")
struct EventIDTests {

    // MARK: - Basic Initialization

    @Test
    func `ID can be created from UInt literal`() {
        let id: ISO_9945.Kernel.Event.ID = 42
        #expect(id == 42)
    }

    @Test
    func `ID zero is valid`() {
        let id: ISO_9945.Kernel.Event.ID = 0
        #expect(id == 0)
    }

    @Test
    func `ID max value`() {
        let id = ISO_9945.Kernel.Event.ID(_unchecked: UInt.max)
        #expect(id.underlying == UInt.max)
    }

    // MARK: - Descriptor Conversion

    @Test
    func `ID from descriptor reflects the fd raw value`() throws {
        // Use a real owned descriptor from pipe(2) so the borrow into
        // ISO_9945.Kernel.Event.ID(descriptor:) does not alias an unrelated fd.
        // pipe goes out of scope at function exit; both ends close cleanly
        // through their respective ISO_9945.Kernel.Descriptor deinits.
        let pipe = try ISO_9945.Kernel.Pipe.pipe()
        let id = ISO_9945.Kernel.Event.ID(descriptor: pipe.read)
        #expect(id.underlying == UInt(bitPattern: Int(pipe.read._rawValue)))
    }

    @Test
    func `Round-trip from descriptor through ID is symmetric`() throws {
        // Verify the round-trip mathematically: the ID's raw value fits in
        // Int32 (so ISO_9945.Kernel.Descriptor.init?(_:) would succeed) and the bit
        // pattern matches the original descriptor's fd. This avoids actually
        // constructing the recovered Descriptor, which would alias pipe.read
        // and double-close at scope exit.
        let pipe = try ISO_9945.Kernel.Pipe.pipe()
        let originalRaw = pipe.read._rawValue
        let id = ISO_9945.Kernel.Event.ID(descriptor: pipe.read)
        #expect(id.underlying <= UInt(Int32.max))
        #expect(Int32(id.underlying) == originalRaw)
    }

    @Test
    func `Descriptor from ID fails for large values`() {
        // Values larger than Int32.max cannot be converted to a descriptor.
        // No fd is constructed (init? returns nil), so no aliasing risk.
        let largeID = ISO_9945.Kernel.Event.ID(_unchecked: UInt(Int32.max) + 1)
        let descriptor = ISO_9945.Kernel.Descriptor(largeID)
        let isNil = (descriptor == nil)
        #expect(isNil)
    }

    // MARK: - Conformances

    @Test
    func `ID is Equatable`() {
        let a: ISO_9945.Kernel.Event.ID = 42
        let b: ISO_9945.Kernel.Event.ID = 42
        let c: ISO_9945.Kernel.Event.ID = 43
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `ID is Hashable`() {
        var set = Set<ISO_9945.Kernel.Event.ID>()
        set.insert(ISO_9945.Kernel.Event.ID(_unchecked: 1))
        set.insert(ISO_9945.Kernel.Event.ID(_unchecked: 2))
        set.insert(ISO_9945.Kernel.Event.ID(_unchecked: 1))  // duplicate
        #expect(set.count == 2)
    }

    @Test
    func `ID is Sendable`() {
        let id: ISO_9945.Kernel.Event.ID = 42
        let sendable: any Sendable = id
        #expect(sendable is ISO_9945.Kernel.Event.ID)
    }

    @Test
    func `ID is Comparable`() {
        let a: ISO_9945.Kernel.Event.ID = 10
        let b: ISO_9945.Kernel.Event.ID = 20
        #expect(a < b)
        #expect(b > a)
    }
}
