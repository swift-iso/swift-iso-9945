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
    @Test
    func `explicit init sets read/write fields`() {
        let mode = Kernel.File.Open.Mode(read: true, write: false)
        #expect(mode.read == true)
        #expect(mode.write == false)
    }

    @Test
    func `.read constant is read-only`() {
        let mode = Kernel.File.Open.Mode.read
        #expect(mode.read == true)
        #expect(mode.write == false)
    }

    @Test
    func `.write constant is write-only`() {
        let mode = Kernel.File.Open.Mode.write
        #expect(mode.read == false)
        #expect(mode.write == true)
    }

    @Test
    func `.readWrite constant is read+write`() {
        let mode = Kernel.File.Open.Mode.readWrite
        #expect(mode.read == true)
        #expect(mode.write == true)
    }
}

// MARK: - Conformances

extension Kernel.File.Open.Mode.Test.Unit {
    @Test
    func `Mode is Sendable`() {
        let mode: any Sendable = Kernel.File.Open.Mode.read
        #expect(mode is Kernel.File.Open.Mode)
    }

    @Test
    func `Mode is Equatable`() {
        let a = Kernel.File.Open.Mode(read: true, write: false)
        let b = Kernel.File.Open.Mode(read: true, write: false)
        let c = Kernel.File.Open.Mode(read: false, write: true)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Mode is Hashable`() {
        var set = Set<Kernel.File.Open.Mode>()
        set.insert(.read)
        set.insert(.write)
        set.insert(.read)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Open.Mode.Test.EdgeCase {
    @Test
    func `.read and .write are distinct modes`() {
        #expect(Kernel.File.Open.Mode.read != Kernel.File.Open.Mode.write)
    }

    @Test
    func `.readWrite combines both flags`() {
        let rw = Kernel.File.Open.Mode.readWrite
        #expect(rw.read && rw.write)
    }

    @Test
    func `empty mode has neither flag set`() {
        let empty = Kernel.File.Open.Mode(read: false, write: false)
        #expect(!empty.read)
        #expect(!empty.write)
    }
}
