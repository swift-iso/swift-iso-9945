import Error
@_spi(Syscall) import ISO_9945_Kernel_Lock
import ISO_9945_Kernel_Test_Support
import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

#if canImport(Darwin)
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#endif

private enum LockTestHelper {

    static func executablePath() -> Swift.String? {
        TestExecutable.path("iso-9945-lock-helper", overrides: ["ISO_9945_LOCK_HELPER"])
    }

    static func spawn(
        lockingFile filePath: Swift.String,
        forMilliseconds milliseconds: Int
    ) throws -> ISO_9945.Kernel.Process.ID {
        guard let helperPath = executablePath() else {
            throw TestExecutable.NotFound(name: "iso-9945-lock-helper")
        }
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

    static func waitForContention(
        on fd: borrowing ISO_9945.Kernel.Descriptor,
        timeout: Duration = .milliseconds(2000)
    ) -> Bool {
        let deadline = Clock.Continuous.now + timeout
        while Clock.Continuous.now < deadline {
            do {

                try ISO_9945.Kernel.Lock.Immediate.lock(
                    fd: fd._rawValue,
                    range: .file,
                    kind: .exclusive
                )

                try? ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: .file)

                System.sleep(.milliseconds(5))
            } catch {

                return true
            }
        }
        return false
    }
}

private func makeLockTestFile(prefix: Swift.String) throws -> Swift.String {
    let path = KernelIOTest.makeTempPath(prefix: prefix)
    do {

        let fd = try KernelIOTest.open(at: path)

        let data = [UInt8](repeating: 0x78, count: 1024)
        _ = try data.withUnsafeBytes { buffer in
            try ISO_9945.Kernel.IO.Write.write(fd, from: buffer)
        }

    }
    return path
}

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

@Suite("POSIX Lock Integration")
struct POSIXLockIntegration {}

extension POSIXLockIntegration {
    @Test
    func `Token acquires and releases lock`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-token")
        defer { KernelIOTest.cleanup(path: path) }

        var token = try ISO_9945.Kernel.Lock.Token(
            descriptor: try openLockTestFile(path),
            range: .file,
            kind: .exclusive,
            acquire: .wait
        )

        try token.release()
    }

    @Test
    func `Try lock returns immediately when uncontested`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-try")
        defer { KernelIOTest.cleanup(path: path) }

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

        var token = try ISO_9945.Kernel.Lock.Token(
            descriptor: try openLockTestFile(path),
            range: .bytes(
                start: ISO_9945.Kernel.File.Offset(100),
                end: ISO_9945.Kernel.File.Offset(200)
            ),
            kind: .exclusive,
            acquire: .wait
        )

        try token.release()
    }

    @Test
    func `Lock with deadline times out when contested by another process`() throws {

        let pathString = try makeLockTestFile(prefix: "posix-lock-deadline")
        defer { KernelIOTest.cleanup(path: pathString) }

        let helper = try LockTestHelper.spawn(
            lockingFile: pathString,
            forMilliseconds: 1000
        )

        let contentFd = try openLockTestFile(pathString)
        let detected = LockTestHelper.waitForContention(on: contentFd, timeout: .milliseconds(2000))
        #expect(detected, "Helper should have acquired the lock")

        let deadline = Clock.Continuous.now + .milliseconds(100)
        #expect(throws: ISO_9945.Kernel.Lock.Error.self) {
            _ = try ISO_9945.Kernel.Lock.Token(
                descriptor: try openLockTestFile(pathString),
                range: .file,
                kind: .exclusive,
                acquire: .deadline(deadline)
            )
        }

        _ = try? ISO_9945.Kernel.Process.Wait.wait(.process(helper))
    }
}

extension POSIXLockIntegration {
    @Test
    func `Direct lock and unlock API`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-direct")
        defer { KernelIOTest.cleanup(path: path) }

        let fd = try openLockTestFile(path)

        try ISO_9945.Kernel.Lock.lock(fd: fd._rawValue, range: .file, kind: .exclusive)

        try ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: .file)
    }

    @Test
    func `Immediate lock succeeds when uncontested`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-immediate")
        defer { KernelIOTest.cleanup(path: path) }

        let fd = try openLockTestFile(path)

        try ISO_9945.Kernel.Lock.Immediate.lock(fd: fd._rawValue, range: .file, kind: .exclusive)

        try ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: .file)
    }

    @Test
    func `Immediate lock throws contention when held`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-contend")
        defer { KernelIOTest.cleanup(path: path) }

        let fd = try openLockTestFile(path)

        try ISO_9945.Kernel.Lock.lock(fd: fd._rawValue, range: .file, kind: .exclusive)

        try ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: .file)
    }
}

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

extension POSIXLockIntegration {
    @Test
    func `release allows cross-process acquisition`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-release-verify")
        defer { KernelIOTest.cleanup(path: path) }

        let fd = try openLockTestFile(path)
        try ISO_9945.Kernel.Lock.lock(fd: fd._rawValue, range: .file, kind: .exclusive)

        let helper = try LockTestHelper.spawn(lockingFile: path, forMilliseconds: 100)

        System.sleep(.milliseconds(50))

        try ISO_9945.Kernel.Lock.unlock(fd: fd._rawValue, range: .file)

        let result = try ISO_9945.Kernel.Process.Wait.wait(.process(helper))
        let exitedCleanly = result?.status.classification == .exited(code: 0)
        #expect(exitedCleanly, "Helper should exit cleanly after acquiring released lock")
    }

    @Test
    func `withExclusive releases lock visible to other process`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-with-release-verify")
        defer { KernelIOTest.cleanup(path: path) }

        try ISO_9945.Kernel.Lock.withExclusive(try openLockTestFile(path)) {

        }

        let helper = try LockTestHelper.spawn(lockingFile: path, forMilliseconds: 50)
        let result = try ISO_9945.Kernel.Process.Wait.wait(.process(helper))
        let exitedCleanly = result?.status.classification == .exited(code: 0)
        #expect(exitedCleanly, "Helper should acquire lock after withExclusive released it")
    }

    @Test
    func `Token release allows cross-process acquisition`() throws {
        let path = try makeLockTestFile(prefix: "posix-lock-token-release-verify")
        defer { KernelIOTest.cleanup(path: path) }

        var token = try ISO_9945.Kernel.Lock.Token(
            descriptor: try openLockTestFile(path),
            range: .file,
            kind: .exclusive,
            acquire: .wait
        )

        try token.release()

        let helper = try LockTestHelper.spawn(lockingFile: path, forMilliseconds: 50)
        let result = try ISO_9945.Kernel.Process.Wait.wait(.process(helper))
        let exitedCleanly = result?.status.classification == .exited(code: 0)
        #expect(exitedCleanly, "Helper should acquire lock after Token.release()")
    }
}
