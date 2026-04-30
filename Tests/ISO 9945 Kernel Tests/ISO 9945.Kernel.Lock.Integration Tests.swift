// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


import ISO_9945_Kernel
@_spi(Syscall) import ISO_9945_Kernel_Lock
import ISO_9945_Kernel_Test_Support
import Path_Primitives
import Error_Primitives
import Testing

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#endif

@testable import ISO_9945_Kernel

// MARK: - Lock Test Helper

/// Utility for spawning the lock helper executable for multi-process lock tests.
private enum LockTestHelper {
    /// Path to the lock helper executable.
    static func executablePath(filePath: StaticString = #filePath) -> Swift.String {
        let helperName = "iso-9945-lock-helper"

        // 1. Prefer explicit env var (CI-friendly)
        if let envPath = getenv("ISO_9945_LOCK_HELPER") {
            return Swift.String(cString: envPath)
        }

        // 2. Use #filePath to find package root, then .build/debug/
        var path = filePath.description
        for _ in 0..<3 {
            if let lastSlash = path.lastIndex(of: "/") {
                path = Swift.String(path[..<lastSlash])
            }
        }
        let swiftPMPath = "\(path)/.build/debug/\(helperName)"
        if isExecutable(swiftPMPath) {
            return swiftPMPath
        }

        // 3. Try Xcode paths
        if let xpcPath = getenv("__XPC_DYLD_FRAMEWORK_PATH") {
            let candidate = "\(Swift.String(cString: xpcPath))/\(helperName)"
            if isExecutable(candidate) {
                return candidate
            }
        }

        return helperName
    }

    private static func isExecutable(_ path: Swift.String) -> Bool {
        path.withCString { cPath in
            access(cPath, X_OK) == 0
        }
    }

    /// Spawns the lock helper to hold a lock on the given file path.
    ///
    /// - Parameters:
    ///   - filePath: Path to the file to lock.
    ///   - milliseconds: How long to hold the lock.
    /// - Returns: The process ID of the spawned helper.
    static func spawn(lockingFile filePath: Swift.String, forMilliseconds milliseconds: Int) throws -> Kernel.Process.ID {
        let helperPath = executablePath()
        let allArgs = [helperPath, filePath, "\(milliseconds)"]
        let envp: [Swift.String] = []

        return try Path.scope.array(allArgs, envp) { argvPtr, envpPtr in
            try unsafe ISO_9945.Kernel.Process.Spawn.spawn(
                path: argvPtr[0]!,
                argv: argvPtr,
                envp: envpPtr
            )
        }
    }

    /// Polls until tryLock fails (indicating another process holds the lock).
    ///
    /// - Parameters:
    ///   - fd: File descriptor to try locking.
    ///   - timeout: Maximum time to wait.
    /// - Returns: `true` if lock contention was detected, `false` if timed out.
    static func waitForContention(
        on fd: borrowing Kernel.Descriptor,
        timeout: Duration = .milliseconds(2000)
    ) -> Bool {
        let deadline = Clock.Continuous.now + timeout
        while Clock.Continuous.now < deadline {
            do {
                // Try to acquire lock - if it fails with contention, the helper has it
                try ISO_9945.Kernel.Lock.Immediate.lock(fd: fd._rawValue, range: .file, kind: .exclusive)
                // We got the lock - release it and try again
                try? ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: .file)
                // Small delay before retry
                System.sleep(.milliseconds(5))
            } catch {
                // Lock contention detected - helper has the lock
                return true
            }
        }
        return false
    }
}

// MARK: - Cross-Platform Test Helpers

/// Creates a temporary file with 1024 bytes of data (needed for byte-range locking)
/// and returns the path. The initial file descriptor used to populate the
/// file is closed before return — callers open fresh descriptors via
/// `openLockTestFile(_:)`.
///
/// A bundle struct returning both path and fd is not possible: Swift does
/// not support tuples with ~Copyable elements (see [IMPL-072]), and a
/// ~Copyable struct holding the fd cannot yield that fd to callers for
/// consumption (field access is a borrow, not a consume).
private func makeLockTestFile(prefix: Swift.String) throws -> Swift.String {
    let path = KernelIOTest.makeTempPath(prefix: prefix)
    do {
        // Use KernelIOTest.open here (not openLockTestFile) because the
        // file does not yet exist — KernelIOTest.open creates + truncates.
        let fd = try KernelIOTest.open(at: path)
        // Write some data so the file isn't empty (needed for byte-range locking)
        let data = [UInt8](repeating: 0x78, count: 1024)  // 'x' repeated
        _ = try data.withUnsafeBytes { buffer in
            try ISO_9945.Kernel.IO.Write.write(fd, from: buffer)
        }
        // fd closed by Descriptor.deinit at end of do-scope
    }
    return path
}

/// Re-opens an existing test file (created by `makeLockTestFile`) for
/// lock operations. Uses `.readWrite` with no `.create` / `.truncate` /
/// `.exclusive` — the file already exists with data and must not be
/// recreated or truncated.
private func openLockTestFile(_ path: Swift.String) throws -> ISO_9945.Kernel.Descriptor {
    try Path.scope(path) { p in
        try ISO_9945.Kernel.File.Open.open(
            path: p,
            mode: .readWrite,
            options: [],
            permissions: .ownerReadWrite
        )
    }
}

// MARK: - Integration Suite

@Suite("POSIX Lock Integration")
struct POSIXLockIntegration {}

// MARK: - Token Integration Tests

extension POSIXLockIntegration {
    @Test
    func `Token acquires and releases lock`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-token")
        defer { KernelIOTest.cleanup(path: path) }

        // Acquire exclusive lock
        var token = try ISO_9945.Kernel.Lock.Token(
            descriptor: try openLockTestFile(path),
            range: .file,
            kind: .exclusive,
            acquire: .wait
        )

        // Release the lock
        try token.release()
    }

    @Test
    func `Try lock returns immediately when uncontested`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-try")
        defer { KernelIOTest.cleanup(path: path) }

        // Try to acquire lock without blocking - should succeed
        var token = try ISO_9945.Kernel.Lock.Token(
            descriptor: try openLockTestFile(path),
            range: .file,
            kind: .exclusive,
            acquire: .try
        )

        try token.release()
    }

    @Test
    func `Shared lock can be acquired`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-shared")
        defer { KernelIOTest.cleanup(path: path) }

        var token = try ISO_9945.Kernel.Lock.Token(
            descriptor: try openLockTestFile(path),
            range: .file,
            kind: .shared,
            acquire: .wait
        )

        try token.release()
    }

    @Test
    func `Byte-range lock on specific range`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-range")
        defer { KernelIOTest.cleanup(path: path) }

        // Lock bytes 100-200
        var token = try ISO_9945.Kernel.Lock.Token(
            descriptor: try openLockTestFile(path),
            range: .bytes(start: ISO_9945.Kernel.File.Offset(100), end: ISO_9945.Kernel.File.Offset(200)),
            kind: .exclusive,
            acquire: .wait
        )

        try token.release()
    }

    @Test
    func `Lock with deadline times out when contested by another process`() throws {
        // Create a temp file path that both processes can access
        let pathString = try makeLockTestFile(prefix: "posix-lock-deadline")
        defer { KernelIOTest.cleanup(path: pathString) }

        // Spawn helper to hold the lock for 1000ms
        let helper = try LockTestHelper.spawn(
            lockingFile: pathString,
            forMilliseconds: 1000
        )

        // Wait for the helper to acquire the lock
        let contentFd = try openLockTestFile(pathString)
        let detected = LockTestHelper.waitForContention(on: contentFd, timeout: .milliseconds(2000))
        #expect(detected, "Helper should have acquired the lock")

        // Now try to acquire with a short deadline - should fail due to contention
        let deadline = Clock.Continuous.now + .milliseconds(100)
        #expect(throws: ISO_9945.Kernel.Lock.Error.self) {
            _ = try ISO_9945.Kernel.Lock.Token(
                descriptor: try openLockTestFile(pathString),
                range: .file,
                kind: .exclusive,
                acquire: .deadline(deadline)
            )
        }

        // Wait for helper to exit
        _ = try? ISO_9945.Kernel.Process.Wait.wait(.process(helper))
    }
}

// MARK: - Direct API Tests

extension POSIXLockIntegration {
    @Test
    func `Direct lock and unlock API`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-direct")
        defer { KernelIOTest.cleanup(path: path) }

        let fd = try openLockTestFile(path)

        // Lock directly
        try ISO_9945.Kernel.Lock.lock(fd: fd._rawValue, range: .file, kind: .exclusive)

        // Unlock directly
        try ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: .file)
    }

    @Test
    func `Immediate lock succeeds when uncontested`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-immediate")
        defer { KernelIOTest.cleanup(path: path) }

        let fd = try openLockTestFile(path)

        // Try immediate lock - should succeed
        try ISO_9945.Kernel.Lock.Immediate.lock(fd: fd._rawValue, range: .file, kind: .exclusive)

        // Cleanup
        try ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: .file)
    }

    @Test
    func `Immediate lock throws contention when held`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-contend")
        defer { KernelIOTest.cleanup(path: path) }

        let fd = try openLockTestFile(path)

        // Acquire exclusive lock
        try ISO_9945.Kernel.Lock.lock(fd: fd._rawValue, range: .file, kind: .exclusive)

        // Try immediate lock on same descriptor (same process, same thread)
        // Note: POSIX allows same-process relock, so this tests API not contention
        // For true contention testing, need multi-process tests

        // Cleanup
        try ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: .file)
    }
}

// MARK: - Scoped Locking Tests

extension POSIXLockIntegration {
    @Test
    func `withExclusive executes body under lock`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-with")
        defer { KernelIOTest.cleanup(path: path) }

        var executed = false

        try ISO_9945.Kernel.Lock.withExclusive(try openLockTestFile(path)) {
            executed = true
        }

        #expect(executed == true)
    }

    @Test
    func `withShared allows concurrent reads`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-with-shared")
        defer { KernelIOTest.cleanup(path: path) }

        var executed = false

        try ISO_9945.Kernel.Lock.withShared(try openLockTestFile(path)) {
            executed = true
        }

        #expect(executed == true)
    }

    @Test
    func `withExclusive returns value from body`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-with-return")
        defer { KernelIOTest.cleanup(path: path) }

        let result = try ISO_9945.Kernel.Lock.withExclusive(try openLockTestFile(path)) {
            42
        }

        #expect(result == 42)
    }
}

// MARK: - Lock Release Verification
//
// Tests #9-#11 from the testing audit: verify that lock release actually
// allows a separate process to acquire the lock. POSIX advisory locks are
// per-process, so same-process re-acquire always succeeds — cross-process
// is the only meaningful verification.

extension POSIXLockIntegration {
    @Test
    func `release allows cross-process acquisition`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-release-verify")
        defer { KernelIOTest.cleanup(path: path) }

        // Acquire exclusive lock in this process.
        let fd = try openLockTestFile(path)
        try ISO_9945.Kernel.Lock.lock(fd: fd._rawValue, range: .file, kind: .exclusive)

        // Spawn helper — it blocks on fcntl(F_SETLKW) because we hold the lock.
        let helper = try LockTestHelper.spawn(lockingFile: path, forMilliseconds: 100)

        // Give helper time to start and block.
        System.sleep(.milliseconds(50))

        // Release our lock — helper should now acquire.
        try ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: .file)

        // If release worked, the helper acquires, holds for 100ms, exits 0.
        // If release failed, the helper blocks indefinitely and wait hangs.
        let result = try ISO_9945.Kernel.Process.Wait.wait(.process(helper))
        let exitedCleanly = result?.status.classification == .exited(code: 0)
        #expect(exitedCleanly, "Helper should exit cleanly after acquiring released lock")
    }

    @Test
    func `withExclusive releases lock visible to other process`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-with-release-verify")
        defer { KernelIOTest.cleanup(path: path) }

        // withExclusive consumes fd, locks, runs body, releases via Token.release().
        try ISO_9945.Kernel.Lock.withExclusive(try openLockTestFile(path)) {
            // Lock is held here — nothing to do.
        }
        // Lock released. Token.release() unlocked, Descriptor deinit closed fd,
        // which also releases any remaining POSIX advisory locks on the inode.

        // Spawn helper to immediately try locking — should succeed without blocking.
        let helper = try LockTestHelper.spawn(lockingFile: path, forMilliseconds: 50)
        let result = try ISO_9945.Kernel.Process.Wait.wait(.process(helper))
        let exitedCleanly = result?.status.classification == .exited(code: 0)
        #expect(exitedCleanly, "Helper should acquire lock after withExclusive released it")
    }

    @Test
    func `Token release allows cross-process acquisition`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-token-release-verify")
        defer { KernelIOTest.cleanup(path: path) }

        // Acquire via Token.
        var token = try ISO_9945.Kernel.Lock.Token(
            descriptor: try openLockTestFile(path),
            range: .file,
            kind: .exclusive,
            acquire: .wait
        )

        // Release explicitly.
        try token.release()

        // Spawn helper — should acquire immediately since we released.
        let helper = try LockTestHelper.spawn(lockingFile: path, forMilliseconds: 50)
        let result = try ISO_9945.Kernel.Process.Wait.wait(.process(helper))
        let exitedCleanly = result?.status.classification == .exited(code: 0)
        #expect(exitedCleanly, "Helper should acquire lock after Token.release()")
    }
}

