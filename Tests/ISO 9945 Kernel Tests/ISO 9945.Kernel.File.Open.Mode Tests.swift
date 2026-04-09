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

extension Kernel.File.Open.Mode {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.Open.Mode.Test.Unit {
    @Test("explicit init sets read/write fields")
    func explicitInit() {
        let mode = Kernel.File.Open.Mode(read: true, write: false)
        #expect(mode.read == true)
        #expect(mode.write == false)
    }

    @Test(".read constant is read-only")
    func readConstant() {
        let mode = Kernel.File.Open.Mode.read
        #expect(mode.read == true)
        #expect(mode.write == false)
    }

    @Test(".write constant is write-only")
    func writeConstant() {
        let mode = Kernel.File.Open.Mode.write
        #expect(mode.read == false)
        #expect(mode.write == true)
    }

    @Test(".readWrite constant is read+write")
    func readWriteConstant() {
        let mode = Kernel.File.Open.Mode.readWrite
        #expect(mode.read == true)
        #expect(mode.write == true)
    }
}

// MARK: - Conformances

extension Kernel.File.Open.Mode.Test.Unit {
    @Test("Mode is Sendable")
    func isSendable() {
        let mode: any Sendable = Kernel.File.Open.Mode.read
        #expect(mode is Kernel.File.Open.Mode)
    }

    @Test("Mode is Equatable")
    func isEquatable() {
        let a = Kernel.File.Open.Mode(read: true, write: false)
        let b = Kernel.File.Open.Mode(read: true, write: false)
        let c = Kernel.File.Open.Mode(read: false, write: true)
        #expect(a == b)
        #expect(a != c)
    }

    @Test("Mode is Hashable")
    func isHashable() {
        var set = Set<Kernel.File.Open.Mode>()
        set.insert(.read)
        set.insert(.write)
        set.insert(.read)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Open.Mode.Test.EdgeCase {
    @Test(".read and .write are distinct modes")
    func distinctConstants() {
        #expect(Kernel.File.Open.Mode.read != Kernel.File.Open.Mode.write)
    }

    @Test(".readWrite combines both flags")
    func readWriteCombined() {
        let rw = Kernel.File.Open.Mode.readWrite
        #expect(rw.read && rw.write)
    }

    @Test("empty mode has neither flag set")
    func emptyMode() {
        let empty = Kernel.File.Open.Mode(read: false, write: false)
        #expect(!empty.read)
        #expect(!empty.write)
    }
}
