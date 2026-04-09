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

@_spi(Syscall) public import Kernel_Primitives_Core
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
@_spi(Syscall) public import Kernel_Socket_Primitives
@_spi(Syscall) public import Kernel_Memory_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_Permission_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_Thread_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Clock_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Syscall_Primitives
@_spi(Syscall) public import Kernel_Terminal_Primitives
public import ISO_9945

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
    /// This call blocks until the lock can be acquired.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - range: The byte range to lock.
    ///   - kind: The lock kind (shared or exclusive).
    /// - Throws: `Error.deadlock` if a deadlock is detected,
    ///           `Error.unavailable` if the system lock table is exhausted.

    public static func lock(
        _ descriptor: borrowing Kernel.Descriptor,
        range: Kernel.Lock.Range,
        kind: Kernel.Lock.Kind
    ) throws(Kernel.Lock.Error) {
        var fl = makeFlock(range: range, kind: kind)

        let result = unsafe fcntl(descriptor._rawValue, F_SETLKW, &fl)
        guard result != -1 else {
            throw Kernel.Lock.Error(Kernel.Error.Code.captureErrno())
        }
    }

    /// Releases a lock on a byte range.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor.
    ///   - range: The byte range to unlock.
    /// - Throws: `Error` if unlocking fails.

    public static func unlock(
        _ descriptor: borrowing Kernel.Descriptor,
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

        let result = unsafe fcntl(descriptor._rawValue, F_SETLK, &fl)
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

// MARK: - Immediate (Non-blocking)

extension ISO_9945.Kernel.Lock {
    /// Non-blocking lock operations.
    public enum Immediate {
        /// Attempts to acquire a lock without blocking.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor.
        ///   - range: The byte range to lock.
        ///   - kind: The lock kind (shared or exclusive).
        /// - Throws: `Error.contention` if the lock is held by another process,
        ///           `Error.deadlock` if a deadlock is detected,
        ///           `Error.unavailable` if the system lock table is exhausted.

        public static func lock(
            _ descriptor: borrowing Kernel.Descriptor,
            range: Kernel.Lock.Range,
            kind: Kernel.Lock.Kind
        ) throws(Kernel.Lock.Error) {
            var fl = ISO_9945.Kernel.Lock.makeFlock(range: range, kind: kind)

            let result = unsafe fcntl(descriptor._rawValue, F_SETLK, &fl)
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
