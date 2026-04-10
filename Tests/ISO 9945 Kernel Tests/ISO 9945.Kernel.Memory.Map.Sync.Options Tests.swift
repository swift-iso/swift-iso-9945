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
import ISO_9945
import Kernel_Primitives_Core
import Kernel_Descriptor_Primitives
import Kernel_Event_Primitives
import Kernel_IO_Primitives
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Kernel_Error_Primitives

@testable import ISO_9945_Kernel

extension Kernel.Memory.Map.Sync.Options {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Memory.Map.Sync.Options.Test.Unit {
    @Test("Options from rawValue")
    func rawValueInit() {
        let flags = Kernel.Memory.Map.Sync.Options(rawValue: 0)
        #expect(flags.rawValue == 0)
    }

    @Test("sync constant exists")
    func syncConstant() {
        let flags = Kernel.Memory.Map.Sync.Options.sync
        _ = flags.rawValue
    }

    @Test("async constant exists")
    func asyncConstant() {
        let flags = Kernel.Memory.Map.Sync.Options.async
        _ = flags.rawValue
    }

    @Test("invalidate constant exists")
    func invalidateConstant() {
        let flags = Kernel.Memory.Map.Sync.Options.invalidate
        _ = flags.rawValue
    }
}

// MARK: - Operators

extension Kernel.Memory.Map.Sync.Options.Test.Unit {
    @Test("bitwise OR combines flags")
    func bitwiseOrCombines() {
        let sync = Kernel.Memory.Map.Sync.Options.sync
        let invalidate = Kernel.Memory.Map.Sync.Options.invalidate
        let combined = sync | invalidate

        #expect(combined.rawValue == (sync.rawValue | invalidate.rawValue))
    }
}

// MARK: - Conformance Tests

extension Kernel.Memory.Map.Sync.Options.Test.Unit {
    @Test("Options is Sendable")
    func isSendable() {
        let flags: any Sendable = Kernel.Memory.Map.Sync.Options.sync
        #expect(flags is Kernel.Memory.Map.Sync.Options)
    }

    @Test("Options is Equatable")
    func isEquatable() {
        let a = Kernel.Memory.Map.Sync.Options.sync
        let b = Kernel.Memory.Map.Sync.Options.sync
        let c = Kernel.Memory.Map.Sync.Options.async
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Options is Hashable")
    func isHashable() {
        var set = Set<Kernel.Memory.Map.Sync.Options>()
        set.insert(.sync)
        set.insert(.async)
        set.insert(.sync)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.Memory.Map.Sync.Options.Test.EdgeCase {
    @Test("sync and async are distinct")
    func syncAsyncDistinct() {
        let sync = Kernel.Memory.Map.Sync.Options.sync
        let async = Kernel.Memory.Map.Sync.Options.async
        #expect(sync != async)
    }

    @Test("all flags are distinct")
    func allOptionsDistinct() {
        let flags: [Kernel.Memory.Map.Sync.Options] = [
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
