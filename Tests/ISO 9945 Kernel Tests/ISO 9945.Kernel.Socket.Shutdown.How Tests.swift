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

import ISO_9945_Kernel
import Tagged_Primitives_Standard_Library_Integration
// Tests use Apple native Testing framework
import Testing

extension ISO_9945.Kernel.Socket.Shutdown.How {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.Socket.Shutdown.How.Test.Unit {
    @Test
    func `How type exists`() {
        let _: ISO_9945.Kernel.Socket.Shutdown.How.Type = ISO_9945.Kernel.Socket.Shutdown.How.self
    }

    @Test
    func `read case has rawValue 0`() {
        let how = ISO_9945.Kernel.Socket.Shutdown.How.read
        #expect(how.rawValue == 0)
    }

    @Test
    func `write case has rawValue 1`() {
        let how = ISO_9945.Kernel.Socket.Shutdown.How.write
        #expect(how.rawValue == 1)
    }

    @Test
    func `both case has rawValue 2`() {
        let how = ISO_9945.Kernel.Socket.Shutdown.How.both
        #expect(how.rawValue == 2)
    }
}

// MARK: - Conformance Tests

extension ISO_9945.Kernel.Socket.Shutdown.How.Test.Unit {
    @Test
    func `How is Sendable`() {
        let value: any Sendable = ISO_9945.Kernel.Socket.Shutdown.How.read
        #expect(value is ISO_9945.Kernel.Socket.Shutdown.How)
    }

    @Test
    func `How is Equatable`() {
        #expect(ISO_9945.Kernel.Socket.Shutdown.How.read == ISO_9945.Kernel.Socket.Shutdown.How.read)
        #expect(ISO_9945.Kernel.Socket.Shutdown.How.read != ISO_9945.Kernel.Socket.Shutdown.How.write)
    }

    @Test
    func `How is Hashable`() {
        var set = Set<ISO_9945.Kernel.Socket.Shutdown.How>()
        set.insert(.read)
        set.insert(.write)
        set.insert(.both)
        set.insert(.read)  // duplicate
        #expect(set.count == 3)
    }
}

// MARK: - RawValue Roundtrip Tests

extension ISO_9945.Kernel.Socket.Shutdown.How.Test.Unit {
    @Test
    func `How from rawValue 0 is read`() {
        let how = ISO_9945.Kernel.Socket.Shutdown.How(rawValue: 0)
        #expect(how == .read)
    }

    @Test
    func `How from rawValue 1 is write`() {
        let how = ISO_9945.Kernel.Socket.Shutdown.How(rawValue: 1)
        #expect(how == .write)
    }

    @Test
    func `How from rawValue 2 is both`() {
        let how = ISO_9945.Kernel.Socket.Shutdown.How(rawValue: 2)
        #expect(how == .both)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.Socket.Shutdown.How.Test.EdgeCase {
    @Test
    func `How from invalid rawValue is nil`() {
        let how = ISO_9945.Kernel.Socket.Shutdown.How(rawValue: 99)
        #expect(how == nil)
    }

    @Test
    func `All cases are distinct`() {
        let cases: [ISO_9945.Kernel.Socket.Shutdown.How] = [.read, .write, .both]
        let rawValues = cases.map(\.rawValue)
        let uniqueRawValues = Set(rawValues)
        #expect(uniqueRawValues.count == cases.count)
    }
}
