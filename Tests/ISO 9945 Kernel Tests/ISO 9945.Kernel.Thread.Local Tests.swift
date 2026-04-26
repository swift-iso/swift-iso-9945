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
import Kernel_Thread_Primitives
import Testing

@testable import ISO_9945_Kernel

@Suite("ISO_9945.Kernel.Thread.Local")
struct LocalTests {
    @Suite struct Unit {}
    @Suite struct Lifecycle {}
}

extension LocalTests.Unit {

    @Test
    func `freshly-allocated slot reads as nil`() {
        let local = ISO_9945.Kernel.Thread.Local()
        unsafe (#expect(local.value == nil))
    }

    @Test
    func `set then get returns the same pointer`() {
        let local = ISO_9945.Kernel.Thread.Local()
        let buffer = unsafe UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        defer { unsafe buffer.deallocate() }
        let raw = unsafe UnsafeMutableRawPointer(buffer)

        unsafe (local.value = raw)
        unsafe (#expect(local.value == raw))
    }

    @Test
    func `set to nil clears the slot`() {
        let local = ISO_9945.Kernel.Thread.Local()
        let buffer = unsafe UnsafeMutablePointer<UInt64>.allocate(capacity: 1)
        defer { unsafe buffer.deallocate() }
        unsafe (local.value = UnsafeMutableRawPointer(buffer))
        unsafe (#expect(local.value != nil))

        unsafe (local.value = nil)
        unsafe (#expect(local.value == nil))
    }

    @Test
    func `multiple Local instances have independent slots`() {
        let a = ISO_9945.Kernel.Thread.Local()
        let b = ISO_9945.Kernel.Thread.Local()
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

extension LocalTests.Lifecycle {

    @Test
    func `Local can be allocated and deallocated repeatedly`() {
        // Stress-test the pthread_key_create / pthread_key_delete cycle.
        // POSIX guarantees PTHREAD_KEYS_MAX (typically 128 or 1024) — the
        // delete must reliably free the key for reuse.
        for _ in 0..<200 {
            let local = ISO_9945.Kernel.Thread.Local()
            unsafe (local.value = nil)
            // local goes out of scope — pthread_key_delete fires
            _ = local
        }
    }
}
