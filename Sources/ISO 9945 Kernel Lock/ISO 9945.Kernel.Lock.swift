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

@_spi(Syscall) public import ISO_9945_Kernel_Descriptor

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX File Locking

extension ISO_9945.Kernel.Lock {
    /// Acquires a lock on a byte range (blocking).
    ///
    /// Wraps `fcntl(fd, F_SETLKW, &flock)`. Throws `Kernel.Lock.Error` (the
    /// L1 lock-error type) on failure — error mapping stays at L2 because
    /// the L2 Token type internally consumes this surface and depends on
    /// the typed error throw. Pattern A's typed-descriptor parameter has
    /// been replaced with a raw `fd: Int32`. The L3-policy wrapper
    /// (`POSIX.Kernel.Lock.lock(_:range:kind:)` in swift-posix) calls this
    /// SPI from a typed `borrowing POSIX.Kernel.Descriptor`.
    ///
    /// - Parameters:
    ///   - fd: The file descriptor.
    ///   - range: The byte range to lock.
    ///   - kind: The lock kind (shared or exclusive).
    /// - Throws: `Error.deadlock` if a deadlock is detected,
    ///           `Error.unavailable` if the system lock table is exhausted.
    @_spi(Syscall)
    public static func lock(
        fd: Int32,
        range: Kernel.Lock.Range,
        kind: Kernel.Lock.Kind
    ) throws(Kernel.Lock.Error) {
        var fl = makeFlock(range: range, kind: kind)

        let result = unsafe fcntl(fd, F_SETLKW, &fl)
        guard result != -1 else {
            throw Kernel.Lock.Error(Kernel.Error.Code.captureErrno())
        }
    }

    /// Releases a lock on a byte range.
    ///
    /// Wraps `fcntl(fd, F_SETLK, &flock)` with `F_UNLCK`. The L3-policy
    /// wrapper (`POSIX.Kernel.Lock.unlock(_:range:)` in swift-posix) calls
    /// this SPI from a typed `borrowing POSIX.Kernel.Descriptor`.
    ///
    /// - Parameters:
    ///   - fd: The file descriptor.
    ///   - range: The byte range to unlock.
    /// - Throws: `Error` if unlocking fails.
    @_spi(Syscall)
    public static func unlock(
        fd: Int32,
        range: Kernel.Lock.Range
    ) throws(Kernel.Lock.Error) {
        var fl = flock()
        fl.l_type = Int16(F_UNLCK)
        fl.l_whence = Int16(SEEK_SET)

        switch range {
        case .file:
            fl.l_start = 0
            fl.l_len = 0  // 0 means lock to EOF
        case .bytes(let start, let end):
            fl.l_start = off_t(start.rawValue)
            fl.l_len = off_t((end - start).rawValue)
        }

        let result = unsafe fcntl(fd, F_SETLK, &fl)
        guard result != -1 else {
            throw Kernel.Lock.Error(Kernel.Error.Code.captureErrno())
        }
    }

    /// Creates a flock structure for fcntl.

    static func makeFlock(range: Kernel.Lock.Range, kind: Kernel.Lock.Kind) -> flock {
        var fl = flock()

        fl.l_type = kind == .shared ? Int16(F_RDLCK) : Int16(F_WRLCK)
        fl.l_whence = Int16(SEEK_SET)

        switch range {
        case .file:
            // l_start = 0, l_len = 0 means "lock entire file to EOF"
            fl.l_start = 0
            fl.l_len = 0
        case .bytes(let start, let end):
            fl.l_start = off_t(start.rawValue)
            fl.l_len = off_t((end - start).rawValue)
        }

        return fl
    }
}

// MARK: - Typed Convenience (Phase 1.5)

extension ISO_9945.Kernel.Lock {
    /// Acquires a lock on a byte range (blocking) using a typed descriptor.
    ///
    /// Phase 1.5 typed L2 form. Delegates to the raw `lock(fd:range:kind:)` SPI.
    public static func lock(
        _ descriptor: borrowing POSIX.Kernel.Descriptor,
        range: Kernel.Lock.Range,
        kind: Kernel.Lock.Kind
    ) throws(Kernel.Lock.Error) {
        try lock(fd: descriptor._rawValue, range: range, kind: kind)
    }

    /// Releases a lock on a byte range using a typed descriptor.
    ///
    /// Phase 1.5 typed L2 form. Delegates to the raw `unlock(fd:range:)` SPI.
    public static func unlock(
        _ descriptor: borrowing POSIX.Kernel.Descriptor,
        range: Kernel.Lock.Range
    ) throws(Kernel.Lock.Error) {
        try unlock(fd: descriptor._rawValue, range: range)
    }
}

// MARK: - Immediate (Non-blocking)

extension ISO_9945.Kernel.Lock {
    /// Non-blocking lock operations.
    public enum Immediate {
        /// Attempts to acquire a lock without blocking.
        ///
        /// Wraps `fcntl(fd, F_SETLK, &flock)`. The L3-policy wrapper
        /// (`POSIX.Kernel.Lock.Immediate.lock(_:range:kind:)` in swift-posix)
        /// calls this SPI from a typed `borrowing POSIX.Kernel.Descriptor`.
        ///
        /// - Parameters:
        ///   - fd: The file descriptor.
        ///   - range: The byte range to lock.
        ///   - kind: The lock kind (shared or exclusive).
        /// - Throws: `Error.contention` if the lock is held by another process,
        ///           `Error.deadlock` if a deadlock is detected,
        ///           `Error.unavailable` if the system lock table is exhausted.
        @_spi(Syscall)
        public static func lock(
            fd: Int32,
            range: Kernel.Lock.Range,
            kind: Kernel.Lock.Kind
        ) throws(Kernel.Lock.Error) {
            var fl = ISO_9945.Kernel.Lock.makeFlock(range: range, kind: kind)

            let result = unsafe fcntl(fd, F_SETLK, &fl)
            if result == -1 {
                // EAGAIN or EACCES means the lock is held by another process
                if errno == EAGAIN || errno == EACCES {
                    throw .contention
                }
                throw Kernel.Lock.Error(Kernel.Error.Code.captureErrno())
            }
        }
    }
}

extension ISO_9945.Kernel.Lock.Immediate {
    /// Attempts to acquire a non-blocking lock using a typed descriptor.
    ///
    /// Phase 1.5 typed L2 form. Delegates to the raw `lock(fd:range:kind:)` SPI.
    public static func lock(
        _ descriptor: borrowing POSIX.Kernel.Descriptor,
        range: Kernel.Lock.Range,
        kind: Kernel.Lock.Kind
    ) throws(Kernel.Lock.Error) {
        try lock(fd: descriptor._rawValue, range: range, kind: kind)
    }
}

// MARK: - Error Mapping

extension ISO_9945.Kernel.Lock.Error {
    /// Creates a lock error from a platform error code.

    init(_ code: Kernel.Error.Code) {
        switch code {
        case .posix(let errno):
            switch errno {
            case EDEADLK:
                self = .deadlock
            case ENOLCK:
                self = .unavailable
            default:
                // EAGAIN/EACCES are handled in Immediate.lock
                self = .contention
            }
        case .win32:
            self = .contention
        }
    }
}
