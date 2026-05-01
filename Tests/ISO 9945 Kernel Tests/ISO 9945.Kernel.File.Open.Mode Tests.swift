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
import Path_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.File.Open.Mode {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.Open.Mode.Test.Unit {
    @Test
    func `explicit init sets read/write fields`() {
        let mode = ISO_9945.Kernel.File.Open.Mode(read: true, write: false)
        #expect(mode.read == true)
        #expect(mode.write == false)
    }

    @Test
    func `.read constant is read-only`() {
        let mode = ISO_9945.Kernel.File.Open.Mode.read
        #expect(mode.read == true)
        #expect(mode.write == false)
    }

    @Test
    func `.write constant is write-only`() {
        let mode = ISO_9945.Kernel.File.Open.Mode.write
        #expect(mode.read == false)
        #expect(mode.write == true)
    }

    @Test
    func `.readWrite constant is read+write`() {
        let mode = ISO_9945.Kernel.File.Open.Mode.readWrite
        #expect(mode.read == true)
        #expect(mode.write == true)
    }
}

// MARK: - Conformances

extension ISO_9945.Kernel.File.Open.Mode.Test.Unit {
    @Test
    func `Mode is Sendable`() {
        let mode: any Sendable = ISO_9945.Kernel.File.Open.Mode.read
        #expect(mode is ISO_9945.Kernel.File.Open.Mode)
    }

    @Test
    func `Mode is Equatable`() {
        let a = ISO_9945.Kernel.File.Open.Mode(read: true, write: false)
        let b = ISO_9945.Kernel.File.Open.Mode(read: true, write: false)
        let c = ISO_9945.Kernel.File.Open.Mode(read: false, write: true)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Mode is Hashable`() {
        var set = Set<ISO_9945.Kernel.File.Open.Mode>()
        set.insert(.read)
        set.insert(.write)
        set.insert(.read)  // duplicate
        #expect(set.count == 2)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.Open.Mode.Test.EdgeCase {
    @Test
    func `.read and .write are distinct modes`() {
        #expect(ISO_9945.Kernel.File.Open.Mode.read != ISO_9945.Kernel.File.Open.Mode.write)
    }

    @Test
    func `.readWrite combines both flags`() {
        let rw = ISO_9945.Kernel.File.Open.Mode.readWrite
        #expect(rw.read && rw.write)
    }

    @Test
    func `empty mode has neither flag set`() {
        let empty = ISO_9945.Kernel.File.Open.Mode(read: false, write: false)
        #expect(!empty.read)
        #expect(!empty.write)
    }
}
