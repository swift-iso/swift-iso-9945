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

extension Kernel.Memory.Map.Protection {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Protection Tests


    extension Kernel.Memory.Map.Protection.Test.Unit {
        @Test
        func `none has zero raw value`() {
            #expect(Kernel.Memory.Map.Protection.none.rawValue == 0)
        }

        @Test
        func `read write execute are distinct`() {
            let read = Kernel.Memory.Map.Protection.read
            let write = Kernel.Memory.Map.Protection.write
            let execute = Kernel.Memory.Map.Protection.execute

            #expect(read != write)
            #expect(read != execute)
            #expect(write != execute)
        }

        @Test
        func `bitwise OR combines flags`() {
            let read = Kernel.Memory.Map.Protection.read
            let write = Kernel.Memory.Map.Protection.write
            let combined = read | write

            #expect(combined.rawValue == (read.rawValue | write.rawValue))
        }

        @Test
        func `contains checks flag presence`() {
            let read = Kernel.Memory.Map.Protection.read
            let write = Kernel.Memory.Map.Protection.write
            let combined = read | write

            #expect(combined.contains(.read))
            #expect(combined.contains(.write))
            #expect(!combined.contains(.execute))
        }

        @Test
        func `readWrite is read OR write`() {
            let readWrite = Kernel.Memory.Map.Protection.readWrite
            let manual = Kernel.Memory.Map.Protection.read | .write

            #expect(readWrite == manual)
            #expect(readWrite.contains(.read))
            #expect(readWrite.contains(.write))
        }

        @Test
        func `none contains nothing`() {
            let none = Kernel.Memory.Map.Protection.none

            #expect(!none.contains(.read))
            #expect(!none.contains(.write))
            #expect(!none.contains(.execute))
        }

        @Test
        func `Protection is Equatable`() {
            let a = Kernel.Memory.Map.Protection.read
            let b = Kernel.Memory.Map.Protection.read
            let c = Kernel.Memory.Map.Protection.write

            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Protection is Hashable`() {
            var set = Set<Kernel.Memory.Map.Protection>()
            set.insert(.read)
            set.insert(.write)
            set.insert(.read)  // duplicate

            #expect(set.count == 2)
            #expect(set.contains(.read))
            #expect(set.contains(.write))
        }
    }

