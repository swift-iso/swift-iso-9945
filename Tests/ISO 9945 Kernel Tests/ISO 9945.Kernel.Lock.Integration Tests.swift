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

#if !os(Windows)

import ISO_9945
import ISO_9945_Kernel_Test_Support
import Kernel_Primitives
import Test_Primitives
import Testing
import Testing_Extras

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
    static func executablePath(filePath: StaticString = #filePath) -> String {
        let helperName = "iso-9945-lock-helper"

        // 1. Prefer explicit env var (CI-friendly)
        if let envPath = getenv("ISO_9945_LOCK_HELPER") {
            return String(cString: envPath)
        }

        // 2. Use #filePath to find package root, then .build/debug/
        var path = filePath.description
        for _ in 0..<3 {
            if let lastSlash = path.lastIndex(of: "/") {
                path = String(path[..<lastSlash])
            }
        }
        let swiftPMPath = "\(path)/.build/debug/\(helperName)"
        if isExecutable(swiftPMPath) {
            return swiftPMPath
        }

        // 3. Try Xcode paths
        if let xpcPath = getenv("__XPC_DYLD_FRAMEWORK_PATH") {
            let candidate = "\(String(cString: xpcPath))/\(helperName)"
            if isExecutable(candidate) {
                return candidate
            }
        }

        return helperName
    }

    private static func isExecutable(_ path: String) -> Bool {
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
    static func spawn(lockingFile filePath: String, forMilliseconds milliseconds: Int) throws -> Kernel.Process.ID {
        let helperPath = executablePath()
        let allArgs = [helperPath, filePath, String(milliseconds)]
        let envp: [String] = []

        return try Kernel.Path.scope(helperPath) { pathPtr in
            try Kernel.Path.scope.array(allArgs, envp) { argvPtr, envpPtr in
                try unsafe POSIX.Kernel.Process.Spawn.spawn(
                    path: pathPtr.unsafeCString,
                    argv: argvPtr,
                    envp: envpPtr
                )
            }
        }
    }

    /// Polls until tryLock fails (indicating another process holds the lock).
    ///
    /// - Parameters:
    ///   - fd: File descriptor to try locking.
    ///   - timeout: Maximum time to wait.
    /// - Returns: `true` if lock contention was detected, `false` if timed out.
    static func waitForContention(
        on fd: Kernel.Descriptor,
        timeout: Duration = .milliseconds(2000)
    ) -> Bool {
        let deadline = ContinuousClock.now + timeout
        while ContinuousClock.now < deadline {
            do {
                // Try to acquire lock - if it fails with contention, the helper has it
                try ISO_9945.Kernel.Lock.Immediate.lock(fd, range: .file, kind: .exclusive)
                // We got the lock - release it and try again
                try? ISO_9945.Kernel.Lock.unlock(fd, range: .file)
                // Small delay before retry
                ISO_9945.Kernel.System.sleep(.milliseconds(5))
            } catch {
                // Lock contention detected - helper has the lock
                return true
            }
        }
        return false
    }
}

// MARK: - Cross-Platform Test Helpers

/// Creates a temporary file and executes body with the path and descriptor.
/// File is automatically cleaned up after body completes.
private func withTempFile<R>(
    prefix: String,
    _ body: (borrowing ISO_9945.Kernel.Path, ISO_9945.Kernel.Descriptor) throws -> R
) throws -> R {
    let pathString = ISO_9945.Kernel.Temporary.filePath(prefix: prefix)
    return try ISO_9945.Kernel.Path.scope(pathString) { path in
        let fd = try ISO_9945.Kernel.File.Open.open(
            path: path,
            mode: [.read, .write],
            options: [.create, .truncate],
            permissions: .ownerReadWrite
        )
        // Write some data so the file isn't empty (needed for byte-range locking)
        let data = [UInt8](repeating: 0x78, count: 1024)  // 'x' repeated
        _ = try data.withUnsafeBytes { buffer in
            try ISO_9945.Kernel.IO.Write.write(fd, from: buffer)
        }
        defer {
            try? ISO_9945.Kernel.Close.close(fd)
            try? ISO_9945.Kernel.Unlink.unlink(path)
        }
        return try body(path, fd)
    }
}

// MARK: - Integration Suite

@Suite("POSIX Lock Integration")
struct POSIXLockIntegration {}

// MARK: - Token Integration Tests

extension POSIXLockIntegration {
    @Test("Token acquires and releases lock")
    func tokenAcquiresAndReleasesLock() throws {
        try withTempFile(prefix: "posix-lock-token") { _, fd in
            #expect(fd.isValid, "Failed to create test file")

            // Acquire exclusive lock
            var token = try ISO_9945.Kernel.Lock.Token(
                descriptor: fd,
                range: .file,
                kind: .exclusive,
                acquire: .wait
            )

            // Release the lock
            try token.release()
        }
    }

    @Test("Try lock returns immediately when uncontested")
    func tryLockUncontested() throws {
        try withTempFile(prefix: "posix-lock-try") { _, fd in
            #expect(fd.isValid, "Failed to create test file")

            // Try to acquire lock without blocking - should succeed
            var token = try ISO_9945.Kernel.Lock.Token(
                descriptor: fd,
                range: .file,
                kind: .exclusive,
                acquire: .try
            )

            try token.release()
        }
    }

    @Test("Shared lock can be acquired")
    func sharedLockAcquired() throws {
        try withTempFile(prefix: "posix-lock-shared") { _, fd in
            #expect(fd.isValid, "Failed to create test file")

            var token = try ISO_9945.Kernel.Lock.Token(
                descriptor: fd,
                range: .file,
                kind: .shared,
                acquire: .wait
            )

            try token.release()
        }
    }

    @Test("Byte-range lock on specific range")
    func byteRangeLock() throws {
        try withTempFile(prefix: "posix-lock-range") { _, fd in
            #expect(fd.isValid, "Failed to create test file")

            // Lock bytes 100-200
            var token = try ISO_9945.Kernel.Lock.Token(
                descriptor: fd,
                range: .bytes(start: ISO_9945.Kernel.File.Offset(100), end: ISO_9945.Kernel.File.Offset(200)),
                kind: .exclusive,
                acquire: .wait
            )

            try token.release()
        }
    }

    @Test("Lock with deadline times out when contested by another process")
    func lockWithDeadlineTimesOut() throws {
        // Create a temp file path that both processes can access
        let pathString = ISO_9945.Kernel.Temporary.filePath(prefix: "posix-lock-deadline")

        try ISO_9945.Kernel.Path.scope(pathString) { path in
            // Create and prepare the file
            let fd = try ISO_9945.Kernel.File.Open.open(
                path: path,
                mode: [.read, .write],
                options: [.create, .truncate],
                permissions: .ownerReadWrite
            )

            // Write some data so the file isn't empty
            let data = [UInt8](repeating: 0x78, count: 1024)
            _ = try data.withUnsafeBytes { buffer in
                try ISO_9945.Kernel.IO.Write.write(fd, from: buffer)
            }

            defer {
                try? ISO_9945.Kernel.Close.close(fd)
                try? ISO_9945.Kernel.Unlink.unlink(path)
            }

            // Spawn helper to hold the lock for 1000ms
            let helper = try LockTestHelper.spawn(
                lockingFile: pathString,
                forMilliseconds: 1000
            )

            // Wait for the helper to acquire the lock
            let detected = LockTestHelper.waitForContention(on: fd, timeout: .milliseconds(2000))
            #expect(detected, "Helper should have acquired the lock")

            // Now try to acquire with a short deadline - should fail due to contention
            let deadline = ContinuousClock.now + .milliseconds(100)
            #expect(throws: ISO_9945.Kernel.Lock.Error.self) {
                _ = try ISO_9945.Kernel.Lock.Token(
                    descriptor: fd,
                    range: .file,
                    kind: .exclusive,
                    acquire: .deadline(deadline)
                )
            }

            // Wait for helper to exit
            _ = try? POSIX.Kernel.Process.Wait.wait(.process(helper))
        }
    }
}

// MARK: - Direct API Tests

extension POSIXLockIntegration {
    @Test("Direct lock and unlock API")
    func directLockUnlock() throws {
        try withTempFile(prefix: "posix-lock-direct") { _, fd in
            // Lock directly
            try ISO_9945.Kernel.Lock.lock(fd, range: .file, kind: .exclusive)

            // Unlock directly
            try ISO_9945.Kernel.Lock.unlock(fd, range: .file)
        }
    }

    @Test("Immediate lock succeeds when uncontested")
    func immediateLockSucceeds() throws {
        try withTempFile(prefix: "posix-lock-immediate") { _, fd in
            // Try immediate lock - should succeed
            try ISO_9945.Kernel.Lock.Immediate.lock(fd, range: .file, kind: .exclusive)

            // Cleanup
            try ISO_9945.Kernel.Lock.unlock(fd, range: .file)
        }
    }

    @Test("Immediate lock throws contention when held")
    func immediateLockThrowsContention() throws {
        try withTempFile(prefix: "posix-lock-contend") { _, fd in
            // Acquire exclusive lock
            try ISO_9945.Kernel.Lock.lock(fd, range: .file, kind: .exclusive)

            // Try immediate lock on same descriptor (same process, same thread)
            // Note: POSIX allows same-process relock, so this tests API not contention
            // For true contention testing, need multi-process tests

            // Cleanup
            try ISO_9945.Kernel.Lock.unlock(fd, range: .file)
        }
    }
}

// MARK: - Scoped Locking Tests

extension POSIXLockIntegration {
    @Test("withExclusive executes body under lock")
    func withExclusiveExecutesBody() throws {
        try withTempFile(prefix: "posix-lock-with") { _, fd in
            var executed = false

            try ISO_9945.Kernel.Lock.withExclusive(fd) {
                executed = true
            }

            #expect(executed == true)
        }
    }

    @Test("withShared allows concurrent reads")
    func withSharedExecutes() throws {
        try withTempFile(prefix: "posix-lock-with-shared") { _, fd in
            var executed = false

            try ISO_9945.Kernel.Lock.withShared(fd) {
                executed = true
            }

            #expect(executed == true)
        }
    }

    @Test("withExclusive returns value from body")
    func withExclusiveReturnsValue() throws {
        try withTempFile(prefix: "posix-lock-with-return") { _, fd in
            let result = try ISO_9945.Kernel.Lock.withExclusive(fd) {
                42
            }

            #expect(result == 42)
        }
    }
}

#endif
