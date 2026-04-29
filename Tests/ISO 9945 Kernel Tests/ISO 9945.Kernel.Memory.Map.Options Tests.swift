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
import Kernel_IO_Primitives
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension Kernel.Memory.Map.Options {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Options Tests


    extension Kernel.Memory.Map.Options.Test.Unit {
        @Test
        func `shared and private are distinct`() {
            let shared = Kernel.Memory.Map.Options.shared
            let priv = Kernel.Memory.Map.Options.private

            #expect(shared != priv)
            #expect(shared.rawValue != priv.rawValue)
        }

        @Test
        func `anonymous flag exists`() {
            let anon = Kernel.Memory.Map.Options.anonymous
            #expect(anon.rawValue != 0)
        }

        @Test
        func `fixed flag exists`() {
            let fixed = Kernel.Memory.Map.Options.fixed
            #expect(fixed.rawValue != 0)
        }

        @Test
        func `bitwise OR combines flags`() {
            let priv = Kernel.Memory.Map.Options.private
            let anon = Kernel.Memory.Map.Options.anonymous
            let combined = priv | anon

            #expect(combined.rawValue == (priv.rawValue | anon.rawValue))
        }

        @Test
        func `Options is Equatable`() {
            let a = Kernel.Memory.Map.Options.shared
            let b = Kernel.Memory.Map.Options.shared
            let c = Kernel.Memory.Map.Options.private

            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Options is Hashable`() {
            var set = Set<Kernel.Memory.Map.Options>()
            set.insert(.shared)
            set.insert(.private)
            set.insert(.shared)  // duplicate

            #expect(set.count == 2)
            #expect(set.contains(.shared))
            #expect(set.contains(.private))
        }

        @Test
        func `all flags are distinct`() {
            let shared = Kernel.Memory.Map.Options.shared
            let priv = Kernel.Memory.Map.Options.private
            let anon = Kernel.Memory.Map.Options.anonymous
            let fixed = Kernel.Memory.Map.Options.fixed

            let flags = [shared, priv, anon, fixed]
            let rawValues = flags.map(\.rawValue)
            let uniqueRawValues = Set(rawValues)

            #expect(uniqueRawValues.count == flags.count)
        }
    }

