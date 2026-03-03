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
import ISO_9945
@_spi(Syscall) import Kernel_Primitives

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

    @Test("ID from descriptor")
    func fromDescriptor() {
        let descriptor = Kernel.Descriptor(_rawValue: 5)
        let id = Kernel.Event.ID(descriptor: descriptor)
        #expect(id == 5)
    }

    @Test("Descriptor from ID roundtrip")
    func descriptorRoundtrip() {
        let descriptor = Kernel.Descriptor(_rawValue: 10)
        let id = Kernel.Event.ID(descriptor: descriptor)
        let recovered = Kernel.Descriptor(id)
        #expect(recovered == Kernel.Descriptor(_rawValue: 10))
    }

    @Test("Descriptor from ID fails for large values")
    func descriptorFromLargeIDFails() {
        // Values larger than Int32.max cannot be converted to a descriptor
        let largeID = Kernel.Event.ID(__unchecked: (), UInt(Int32.max) + 1)
        let descriptor = Kernel.Descriptor(largeID)
        #expect(descriptor == nil)
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
