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

import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
@_spi(Syscall) import ISO_9945_Kernel_Lock
import Path_Primitives
import Error_Primitives
// Tests use Apple native Testing framework
import Testing
import Tagged_Primitives_Standard_Library_Integration

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Lock {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Range Unit Tests

extension ISO_9945.Kernel.Lock.Test.Unit {
    @Test
    func `Range.file is equatable`() {
        let r1 = ISO_9945.Kernel.Lock.Range.file
        let r2 = ISO_9945.Kernel.Lock.Range.file
        #expect(r1 == r2)
    }

    @Test
    func `Range.bytes is equatable`() {
        let r1 = ISO_9945.Kernel.Lock.Range.bytes(start: ISO_9945.Kernel.File.Offset(10), end: ISO_9945.Kernel.File.Offset(110))
        let r2 = ISO_9945.Kernel.Lock.Range.bytes(start: ISO_9945.Kernel.File.Offset(10), end: ISO_9945.Kernel.File.Offset(110))
        let r3 = ISO_9945.Kernel.Lock.Range.bytes(start: ISO_9945.Kernel.File.Offset(20), end: ISO_9945.Kernel.File.Offset(120))

        #expect(r1 == r2)
        #expect(r1 != r3)
    }

    @Test
    func `Range.file and Range.bytes are not equal`() {
        let file = ISO_9945.Kernel.Lock.Range.file
        let bytes = ISO_9945.Kernel.Lock.Range.bytes(start: .zero, end: .zero)

        #expect(file != bytes)
    }

    @Test
    func `Range.bytes with length convenience`() {
        let range = ISO_9945.Kernel.Lock.Range.bytes(start: ISO_9945.Kernel.File.Offset(100), length: ISO_9945.Kernel.File.Size(100))
        #expect(range == .bytes(start: ISO_9945.Kernel.File.Offset(100), end: ISO_9945.Kernel.File.Offset(200)))
    }
}

// MARK: - Kind Unit Tests

extension ISO_9945.Kernel.Lock.Test.Unit {
    @Test
    func `Kind.shared and Kind.exclusive`() {
        let shared = ISO_9945.Kernel.Lock.Kind.shared
        let exclusive = ISO_9945.Kernel.Lock.Kind.exclusive

        #expect(shared != exclusive)
        #expect(shared == .shared)
        #expect(exclusive == .exclusive)
    }
}

// MARK: - Acquire Unit Tests

extension ISO_9945.Kernel.Lock.Test.Unit {
    @Test
    func `Acquire.try case`() {
        let acquire = ISO_9945.Kernel.Lock.Acquire.try
        #expect(acquire == .try)
    }

    @Test
    func `Acquire.wait case`() {
        let acquire = ISO_9945.Kernel.Lock.Acquire.wait
        #expect(acquire == .wait)
    }

    @Test
    func `Acquire.deadline case`() {
        let deadline = Clock.Continuous.now
        let acquire = ISO_9945.Kernel.Lock.Acquire.deadline(deadline)

        if case .deadline(let d) = acquire {
            #expect(d == deadline)
        } else {
            Issue.record("Expected .deadline case")
        }
    }

    @Test
    func `Acquire is equatable`() {
        #expect(ISO_9945.Kernel.Lock.Acquire.try == .try)
        #expect(ISO_9945.Kernel.Lock.Acquire.wait == .wait)
        #expect(ISO_9945.Kernel.Lock.Acquire.try != .wait)
    }
}

// MARK: - Hashable Tests

extension ISO_9945.Kernel.Lock.Test.Unit {
    @Test
    func `Range is hashable`() {
        var set = Set<ISO_9945.Kernel.Lock.Range>()
        set.insert(.file)
        set.insert(.bytes(start: ISO_9945.Kernel.File.Offset(10), end: ISO_9945.Kernel.File.Offset(30)))
        set.insert(.bytes(start: ISO_9945.Kernel.File.Offset(10), end: ISO_9945.Kernel.File.Offset(30)))  // Duplicate

        #expect(set.count == 2)
    }

    @Test
    func `Kind is hashable`() {
        var set = Set<ISO_9945.Kernel.Lock.Kind>()
        set.insert(.shared)
        set.insert(.exclusive)
        set.insert(.shared)  // Duplicate

        #expect(set.count == 2)
    }
}

// MARK: - File Locking API Tests
//
// NOTE: These tests verify API correctness (no crashes, correct return values).
// POSIX fcntl locks are per-process, not per-thread, so same-process tests
// cannot verify contention semantics. Cross-process contention is tested in
// Kernel Tests/ISO_9945.Kernel.Lock.Integration Tests.swift using the _Lock Test Process helper.


    extension ISO_9945.Kernel.Lock.Test.Unit {
        @Test
        func `lock and unlock on file succeeds`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "lock-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }

            try ISO_9945.Kernel.Lock.lock(fd: fd._rawValue, range: .file, kind: .exclusive)
            try ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: .file)
        }

        @Test
        func `Immediate.lock succeeds on uncontested file`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "lock-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }

            try ISO_9945.Kernel.Lock.Immediate.lock(fd: fd._rawValue, range: .file, kind: .exclusive)
            try ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: .file)
        }

        @Test
        func `multiple descriptors can lock same file within process`() throws {
            // NOTE: This demonstrates POSIX behavior where same-process locks don't contend.
            // It is NOT testing that "shared allows multiple" in a meaningful way.
            // Cross-process contention is tested in the Integration Tests.
            let path = KernelIOTest.makeTempPath(prefix: "lock-test")
            let fd1 = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }

            let fd2 = try Path.scope(path) { p in
                try ISO_9945.Kernel.File.Open.open(path: p, mode: .readWrite, options: [], permissions: .privateFile)
            }

            try ISO_9945.Kernel.Lock.lock(fd: fd1._rawValue, range: .file, kind: .shared)
            try ISO_9945.Kernel.Lock.Immediate.lock(fd: fd2._rawValue, range: .file, kind: .shared)

            try ISO_9945.Kernel.Lock.unlock(fd: fd1._rawValue, range: .file)
            try ISO_9945.Kernel.Lock.unlock(fd: fd2._rawValue, range: .file)
        }

        @Test
        func `byte range locks on non-overlapping regions`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "lock-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }

            let range1 = ISO_9945.Kernel.Lock.Range.bytes(start: ISO_9945.Kernel.File.Offset(0), end: ISO_9945.Kernel.File.Offset(100))
            let range2 = ISO_9945.Kernel.Lock.Range.bytes(start: ISO_9945.Kernel.File.Offset(200), end: ISO_9945.Kernel.File.Offset(300))

            try ISO_9945.Kernel.Lock.lock(fd: fd._rawValue, range: range1, kind: .exclusive)
            try ISO_9945.Kernel.Lock.Immediate.lock(fd: fd._rawValue, range: range2, kind: .exclusive)

            try ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: range1)
            try ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: range2)
        }

        @Test
        func `unlock on non-locked region is no-op on POSIX`() throws {
            // POSIX: unlocking a region not locked by the process is a no-op, not an error
            let path = KernelIOTest.makeTempPath(prefix: "lock-test")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }

            // Should not throw
            try ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: .file)
        }
    }

    // MARK: - Token Tests

    extension ISO_9945.Kernel.Lock.Test.Unit {
        @Test
        func `Token acquires and releases lock`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "lock-token")
            defer { KernelIOTest.cleanup(path: path) }

            // Token consumes the descriptor; `release()` unlocks the lock
            // and the descriptor's deinit closes the fd at token destruction.
            var token = try ISO_9945.Kernel.Lock.Token(
                descriptor: try KernelIOTest.open(at: path),
                range: .file,
                kind: .exclusive,
                acquire: .wait
            )
            try token.release()
        }

        @Test
        func `Token with try acquire succeeds when uncontested`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "lock-token")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }

            var token = try ISO_9945.Kernel.Lock.Token(
                descriptor: fd,
                range: .file,
                kind: .exclusive,
                acquire: .try
            )

            try token.release()
        }

        @Test
        func `Token release is idempotent`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "lock-token")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }

            var token = try ISO_9945.Kernel.Lock.Token(
                descriptor: fd,
                range: .file,
                kind: .exclusive
            )

            try token.release()
            try token.release()  // Should be no-op
        }

        @Test
        func `Token with byte range lock`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "lock-token")
            let fd = try KernelIOTest.open(at: path)
            defer { KernelIOTest.cleanup(path: path) }

            let range = ISO_9945.Kernel.Lock.Range.bytes(start: ISO_9945.Kernel.File.Offset(0), end: ISO_9945.Kernel.File.Offset(512))

            var token = try ISO_9945.Kernel.Lock.Token(
                descriptor: fd,
                range: range,
                kind: .shared
            )

            try token.release()
        }
    }

    // MARK: - withExclusive/withShared Tests

    extension ISO_9945.Kernel.Lock.Test.Unit {
        @Test
        func `withExclusive executes body and releases lock`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "lock-with")
            defer { KernelIOTest.cleanup(path: path) }

            var executed = false
            try ISO_9945.Kernel.Lock.withExclusive(try KernelIOTest.open(at: path)) {
                executed = true
            }

            #expect(executed == true)
            // withExclusive consumed the fd. The lock was released via
            // Token.release() in the defer, and the descriptor's deinit
            // closed the fd — which also releases any POSIX advisory
            // locks the process held on the inode.
        }

        @Test
        func `withExclusive returns value from body`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "lock-with")
            defer { KernelIOTest.cleanup(path: path) }

            let result = try ISO_9945.Kernel.Lock.withExclusive(try KernelIOTest.open(at: path)) {
                return 42
            }

            #expect(result == 42)
        }

        @Test
        func `withShared executes body and releases lock`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "lock-with")
            defer { KernelIOTest.cleanup(path: path) }

            var executed = false
            try ISO_9945.Kernel.Lock.withShared(try KernelIOTest.open(at: path)) {
                executed = true
            }

            #expect(executed == true)
        }

        @Test
        func `withExclusive releases lock on throw`() throws {
            let path = KernelIOTest.makeTempPath(prefix: "lock-with")
            defer { KernelIOTest.cleanup(path: path) }

            struct TestError: Swift.Error {}

            do {
                try ISO_9945.Kernel.Lock.withExclusive(try KernelIOTest.open(at: path)) { () throws(TestError) in
                    throw TestError()
                }
                Issue.record("Expected TestError")
            } catch {
                // Expected — body threw TestError, wrapped in Scope.Error.body.
                // The defer in withExclusive still runs, releasing the lock,
                // and the fd is closed as the consumed descriptor is destroyed.
            }
        }
    }

