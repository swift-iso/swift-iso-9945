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

// Tests use Apple native Testing framework
import Testing


extension Kernel.File.Stats.Kind.Device {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.Stats.Kind.Device.Test.Unit {
    @Test
    func `block case exists`() {
        let device = Kernel.File.Stats.Kind.Device.block
        if case .block = device {
            // Expected
        } else {
            Issue.record("Expected .block case")
        }
    }

    @Test
    func `character case exists`() {
        let device = Kernel.File.Stats.Kind.Device.character
        if case .character = device {
            // Expected
        } else {
            Issue.record("Expected .character case")
        }
    }
}

// MARK: - Conformance Tests

extension Kernel.File.Stats.Kind.Device.Test.Unit {
    @Test
    func `Device is Sendable`() {
        let device: any Sendable = Kernel.File.Stats.Kind.Device.block
        #expect(device is Kernel.File.Stats.Kind.Device)
    }

    @Test
    func `Device is Equatable`() {
        let a = Kernel.File.Stats.Kind.Device.block
        let b = Kernel.File.Stats.Kind.Device.block
        let c = Kernel.File.Stats.Kind.Device.character
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Device is Hashable`() {
        var set = Set<Kernel.File.Stats.Kind.Device>()
        set.insert(.block)
        set.insert(.character)
        set.insert(.block)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Stats.Kind.Device.Test.EdgeCase {
    @Test
    func `block and character are distinct`() {
        let block = Kernel.File.Stats.Kind.Device.block
        let character = Kernel.File.Stats.Kind.Device.character
        #expect(block != character)
    }
}
