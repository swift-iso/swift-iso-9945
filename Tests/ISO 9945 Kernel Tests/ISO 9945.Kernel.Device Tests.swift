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
import Tagged_Primitives_Standard_Library_Integration
import ISO_9945_Kernel


extension ISO_9945.Kernel.Device {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Device.Test.Unit {
    @Test
    func `Device type exists`() {
        let _: ISO_9945.Kernel.Device.Type = ISO_9945.Kernel.Device.self
    }

    @Test
    func `Device from rawValue`() {
        let device = ISO_9945.Kernel.Device(rawValue: 42)
        #expect(device.rawValue == 42)
    }

    @Test
    func `Device from UInt64`() {
        let device = ISO_9945.Kernel.Device(100)
        #expect(device.rawValue == 100)
    }
}

// MARK: - ExpressibleByIntegerLiteral Tests

extension ISO_9945.Kernel.Device.Test.Unit {
    @Test
    func `Device from integer literal`() {
        let device: ISO_9945.Kernel.Device = 256
        #expect(device.rawValue == 256)
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.Device.Test.Unit {
    @Test
    func `Device is Sendable`() {
        let value: any Sendable = ISO_9945.Kernel.Device(0)
        #expect(value is ISO_9945.Kernel.Device)
    }

    @Test
    func `Device is Equatable`() {
        let a = ISO_9945.Kernel.Device(100)
        let b = ISO_9945.Kernel.Device(100)
        let c = ISO_9945.Kernel.Device(200)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Device is Hashable`() {
        var set = Set<ISO_9945.Kernel.Device>()
        set.insert(ISO_9945.Kernel.Device(1))
        set.insert(ISO_9945.Kernel.Device(2))
        set.insert(ISO_9945.Kernel.Device(1))  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.Device.Test.EdgeCase {
    @Test
    func `Device zero`() {
        let device = ISO_9945.Kernel.Device(0)
        #expect(device.rawValue == 0)
    }

    @Test
    func `Device max value`() {
        let device = ISO_9945.Kernel.Device(UInt64.max)
        #expect(device.rawValue == UInt64.max)
    }

    @Test
    func `Device rawValue roundtrip`() {
        for value: UInt64 in [0, 1, 100, 0xDEAD_BEEF, UInt64.max] {
            let device = ISO_9945.Kernel.Device(rawValue: value)
            #expect(device.rawValue == value)
        }
    }
}
