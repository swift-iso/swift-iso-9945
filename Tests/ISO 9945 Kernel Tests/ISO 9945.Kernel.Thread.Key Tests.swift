// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import Testing
import Tagged_Primitives_Standard_Library_Integration

@testable import ISO_9945_Kernel

@Suite("ISO_9945.Kernel.Thread.Key")
struct KeyTests {
    @Suite struct Unit {}
    @Suite struct Lifecycle {}
}

extension KeyTests.Unit {

    @Test
    func `freshly-allocated slot reads as nil`() {
        let key = ISO_9945.Kernel.Thread.Key()
        unsafe (#expect(key.value == nil))
    }

    @Test
    func `set then get returns the same pointer`() {
        let key = ISO_9945.Kernel.Thread.Key()
        let buffer = unsafe UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        defer { unsafe buffer.deallocate() }
        let raw = unsafe UnsafeMutableRawPointer(buffer)

        unsafe (key.value = raw)
        unsafe (#expect(key.value == raw))
    }

    @Test
    func `set to nil clears the slot`() {
        let key = ISO_9945.Kernel.Thread.Key()
        let buffer = unsafe UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        defer { unsafe buffer.deallocate() }
        unsafe (key.value = UnsafeMutableRawPointer(buffer))
        unsafe (#expect(key.value != nil))

        unsafe (key.value = nil)
        unsafe (#expect(key.value == nil))
    }

    @Test
    func `multiple Key instances have independent slots`() {
        let a = ISO_9945.Kernel.Thread.Key()
        let b = ISO_9945.Kernel.Thread.Key()
        let bufferA = unsafe UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        let bufferB = unsafe UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        defer { unsafe bufferA.deallocate(); unsafe bufferB.deallocate() }

        unsafe (a.value = UnsafeMutableRawPointer(bufferA))
        unsafe (b.value = UnsafeMutableRawPointer(bufferB))

        unsafe (#expect(a.value == UnsafeMutableRawPointer(bufferA)))
        unsafe (#expect(b.value == UnsafeMutableRawPointer(bufferB)))
        unsafe (#expect(a.value != b.value))
    }
}

extension KeyTests.Lifecycle {

    @Test
    func `Key can be allocated and deallocated repeatedly`() {
        // Stress-test the pthread_key_create / pthread_key_delete cycle.
        // POSIX guarantees PTHREAD_KEYS_MAX (typically 128 or 1024) — the
        // delete must reliably free the key for reuse.
        for _ in 0..<200 {
            let key = ISO_9945.Kernel.Thread.Key()
            unsafe (key.value = nil)
            // key goes out of scope — pthread_key_delete fires
            _ = key
        }
    }
}
