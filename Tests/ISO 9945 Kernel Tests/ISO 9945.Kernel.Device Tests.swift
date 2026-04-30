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


extension Kernel.Device {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Device.Test.Unit {
    @Test
    func `Device type exists`() {
        let _: Kernel.Device.Type = Kernel.Device.self
    }

    @Test
    func `Device from rawValue`() {
        let device = Kernel.Device(rawValue: 42)
        #expect(device.rawValue == 42)
    }

    @Test
    func `Device from UInt64`() {
        let device = Kernel.Device(100)
        #expect(device.rawValue == 100)
    }
}

// MARK: - ExpressibleByIntegerLiteral Tests

extension Kernel.Device.Test.Unit {
    @Test
    func `Device from integer literal`() {
        let device: Kernel.Device = 256
        #expect(device.rawValue == 256)
    }
}

// MARK: - Conformance Tests

extension Kernel.Device.Test.Unit {
    @Test
    func `Device is Sendable`() {
        let value: any Sendable = Kernel.Device(0)
        #expect(value is Kernel.Device)
    }

    @Test
    func `Device is Equatable`() {
        let a = Kernel.Device(100)
        let b = Kernel.Device(100)
        let c = Kernel.Device(200)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Device is Hashable`() {
        var set = Set<Kernel.Device>()
        set.insert(Kernel.Device(1))
        set.insert(Kernel.Device(2))
        set.insert(Kernel.Device(1))  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.Device.Test.EdgeCase {
    @Test
    func `Device zero`() {
        let device = Kernel.Device(0)
        #expect(device.rawValue == 0)
    }

    @Test
    func `Device max value`() {
        let device = Kernel.Device(UInt64.max)
        #expect(device.rawValue == UInt64.max)
    }

    @Test
    func `Device rawValue roundtrip`() {
        for value: UInt64 in [0, 1, 100, 0xDEAD_BEEF, UInt64.max] {
            let device = Kernel.Device(rawValue: value)
            #expect(device.rawValue == value)
        }
    }
}
