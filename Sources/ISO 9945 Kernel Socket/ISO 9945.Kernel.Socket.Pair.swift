// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-posix open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-posix project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket {
    /// Socket pair operations for bidirectional inter-process communication.
    ///
    /// Creates a pair of connected Unix domain sockets. Unlike pipes, socket pairs
    /// are bidirectional—both ends can read and write. Commonly used for:
    /// - Full-duplex IPC between related processes
    /// - Event notification with bidirectional acknowledgment
    /// - Testing network code without actual network I/O
    ///
    /// ## Descriptor Lifecycle
    /// Both descriptors must be closed explicitly via ``Kernel/Close/close(_:)``.
    /// Closing one end causes reads on the other to return EOF and writes to fail.
    public enum Pair: Sendable {}
}

extension ISO_9945.Kernel.Socket.Pair {
    /// Creates a connected pair of Unix domain stream sockets.
    ///
    /// Both sockets are `AF_UNIX` / `SOCK_STREAM` and can be used for
    /// bidirectional communication. Data written to one socket can be read
    /// from the other, and vice versa.
    ///
    /// Per Cycle 21 (L2-syscalls-level), returns `Pair<Int32, Int32>` of raw
    /// fds. L3-policy callers at swift-posix wrap into
    /// `POSIX.Kernel.Socket.Descriptor` via the typealias chain at
    /// swift-kernel L3.
    public typealias Descriptors = Pair<Int32, Int32>

    /// - Returns: A pair of connected socket descriptors (raw POSIX fds).
    /// - Throws: ``Error`` on failure.
    @_spi(Syscall)
    public static func create() throws(Error) -> Descriptors {
        var fds: [Int32] = [0, 0]
        #if canImport(Darwin)
            let result = unsafe Darwin.socketpair(AF_UNIX, SOCK_STREAM, 0, &fds)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.socketpair(AF_UNIX, Int32(SOCK_STREAM.rawValue), 0, &fds)
        #elseif canImport(Musl)
            let result = unsafe Musl.socketpair(AF_UNIX, SOCK_STREAM, 0, &fds)
        #endif
        guard result == 0 else {
            throw currentError()
        }
        return Descriptors(fds[0], fds[1])
    }
}
