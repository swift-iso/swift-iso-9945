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
import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import Kernel_Primitives_Core
import Kernel_Descriptor_Primitives
import Kernel_Event_Primitives
import Kernel_File_Primitives
import Path_Primitives
import Kernel_Process_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension Memory.Map.Sync.Options {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Memory.Map.Sync.Options.Test.Unit {
    @Test
    func `Options from rawValue`() {
        let flags = Memory.Map.Sync.Options(rawValue: 0)
        #expect(flags.rawValue == 0)
    }

    @Test
    func `sync constant exists`() {
        let flags = Memory.Map.Sync.Options.sync
        _ = flags.rawValue
    }

    @Test
    func `async constant exists`() {
        let flags = Memory.Map.Sync.Options.async
        _ = flags.rawValue
    }

    @Test
    func `invalidate constant exists`() {
        let flags = Memory.Map.Sync.Options.invalidate
        _ = flags.rawValue
    }
}

// MARK: - Operators

extension Memory.Map.Sync.Options.Test.Unit {
    @Test
    func `bitwise OR combines flags`() {
        let sync = Memory.Map.Sync.Options.sync
        let invalidate = Memory.Map.Sync.Options.invalidate
        let combined = sync | invalidate

        #expect(combined.rawValue == (sync.rawValue | invalidate.rawValue))
    }
}

// MARK: - Conformance Tests

extension Memory.Map.Sync.Options.Test.Unit {
    @Test
    func `Options is Sendable`() {
        let flags: any Sendable = Memory.Map.Sync.Options.sync
        #expect(flags is Memory.Map.Sync.Options)
    }

    @Test
    func `Options is Equatable`() {
        let a = Memory.Map.Sync.Options.sync
        let b = Memory.Map.Sync.Options.sync
        let c = Memory.Map.Sync.Options.async
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Options is Hashable`() {
        var set = Set<Memory.Map.Sync.Options>()
        set.insert(.sync)
        set.insert(.async)
        set.insert(.sync)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Memory.Map.Sync.Options.Test.EdgeCase {
    @Test
    func `sync and async are distinct`() {
        let sync = Memory.Map.Sync.Options.sync
        let async = Memory.Map.Sync.Options.async
        #expect(sync != async)
    }

    @Test
    func `all flags are distinct`() {
        let flags: [Memory.Map.Sync.Options] = [
            .sync,
            .async,
            .invalidate,
        ]

        for i in 0..<flags.count {
            for j in (i + 1)..<flags.count {
                #expect(flags[i] != flags[j])
            }
        }
    }
}
