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

@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_Socket_Primitives

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
    /// ## Threading
    /// The socketpair syscall is atomic and does not block. The returned
    /// descriptors are created in blocking mode by default.
    ///
    /// ## Blocking Behavior
    /// - **Read**: Blocks until data is available or the peer is closed (EOF)
    /// - **Write**: Blocks if the socket buffer is full
    ///
    /// ## Descriptor Lifecycle
    /// Both descriptors must be closed explicitly. They are independent—closing
    /// one does not automatically close the other.
    ///
    /// ## Errors
    /// - ``Error/platform(_:)``: socketpair syscall failed
    ///
    /// A pair of connected socket descriptors.
    public typealias Descriptors = Pair<Kernel.Socket.Descriptor, Kernel.Socket.Descriptor>

    /// - Returns: A pair of connected socket descriptors.
    /// - Throws: ``Error`` on failure.
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
        return Descriptors(
            Kernel.Socket.Descriptor(_rawValue: fds[0]),
            Kernel.Socket.Descriptor(_rawValue: fds[1])
        )
    }
}
