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
import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
@_spi(Syscall) import Kernel_Primitives_Core
@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_Event_Primitives
@_spi(Syscall) import Kernel_IO_Primitives
@_spi(Syscall) import Kernel_File_Primitives
@_spi(Syscall) import Kernel_Path_Primitives
@_spi(Syscall) import Kernel_Environment_Primitives
@_spi(Syscall) import Kernel_Process_Primitives
@_spi(Syscall) import Kernel_Thread_Primitives
@_spi(Syscall) import Kernel_Error_Primitives

@testable import ISO_9945_Kernel

// Kernel.Event.ID is a typealias to Tagged<Kernel.Event, UInt>
// Test struct pattern cannot be used on typealiases

@Suite("Kernel.Event.ID Tests")
struct EventIDTests {

    // MARK: - Basic Initialization

    @Test("ID can be created from UInt literal")
    func literalInit() {
        let id: Kernel.Event.ID = 42
        #expect(id == 42)
    }

    @Test("ID zero is valid")
    func zeroValue() {
        let id: Kernel.Event.ID = 0
        #expect(id == 0)
    }

    @Test("ID max value")
    func maxValue() {
        let id = Kernel.Event.ID(__unchecked: (), UInt.max)
        #expect(id.rawValue == UInt.max)
    }

    // MARK: - Descriptor Conversion

    @Test("ID from descriptor reflects the fd raw value")
    func fromDescriptor() throws {
        // Use a real owned descriptor from pipe(2) so the borrow into
        // Kernel.Event.ID(descriptor:) does not alias an unrelated fd.
        // pipe goes out of scope at function exit; both ends close cleanly
        // through their respective Kernel.Descriptor deinits.
        let pipe = try ISO_9945.Kernel.Pipe.pipe()
        let id = Kernel.Event.ID(descriptor: pipe.read)
        #expect(id.rawValue == UInt(bitPattern: Int(pipe.read.fileDescriptor)))
    }

    @Test("Round-trip from descriptor through ID is symmetric")
    func descriptorRoundtrip() throws {
        // Verify the round-trip mathematically: the ID's raw value fits in
        // Int32 (so Kernel.Descriptor.init?(_:) would succeed) and the bit
        // pattern matches the original descriptor's fd. This avoids actually
        // constructing the recovered Descriptor, which would alias pipe.read
        // and double-close at scope exit.
        let pipe = try ISO_9945.Kernel.Pipe.pipe()
        let originalRaw = pipe.read.fileDescriptor
        let id = Kernel.Event.ID(descriptor: pipe.read)
        #expect(id.rawValue <= UInt(Int32.max))
        #expect(Int32(id.rawValue) == originalRaw)
    }

    @Test("Descriptor from ID fails for large values")
    func descriptorFromLargeIDFails() {
        // Values larger than Int32.max cannot be converted to a descriptor.
        // No fd is constructed (init? returns nil), so no aliasing risk.
        let largeID = Kernel.Event.ID(__unchecked: (), UInt(Int32.max) + 1)
        let descriptor = Kernel.Descriptor(largeID)
        let isNil = (descriptor == nil)
        #expect(isNil)
    }

    // MARK: - Conformances

    @Test("ID is Equatable")
    func isEquatable() {
        let a: Kernel.Event.ID = 42
        let b: Kernel.Event.ID = 42
        let c: Kernel.Event.ID = 43
        #expect(a == b)
        #expect(a != c)
    }

    @Test("ID is Hashable")
    func isHashable() {
        var set = Set<Kernel.Event.ID>()
        set.insert(Kernel.Event.ID(__unchecked: (), 1))
        set.insert(Kernel.Event.ID(__unchecked: (), 2))
        set.insert(Kernel.Event.ID(__unchecked: (), 1))  // duplicate
        #expect(set.count == 2)
    }

    @Test("ID is Sendable")
    func isSendable() {
        let id: Kernel.Event.ID = 42
        let sendable: any Sendable = id
        #expect(sendable is Kernel.Event.ID)
    }

    @Test("ID is Comparable")
    func isComparable() {
        let a: Kernel.Event.ID = 10
        let b: Kernel.Event.ID = 20
        #expect(a < b)
        #expect(b > a)
    }
}
