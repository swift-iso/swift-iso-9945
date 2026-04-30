// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
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
    /// Socket accept namespace.
    public enum Accept {}
}

// MARK: - Accept raw fd SPI
//
// Per Cycle 21, the L2 Kernel Socket API is canonical-raw: take Int32 fds and
// return Int32 fds via the Result struct. L3-policy callers at swift-posix
// wrap into POSIX.Kernel.Socket.Descriptor; the cross-platform name
// ISO_9945.Kernel.Socket.Descriptor resolves through the swift-kernel L3 typealias
// chain. Typed convenience overloads were dropped per L1-domain-only
// architecture.

extension ISO_9945.Kernel.Socket.Accept {
    /// Accepts an incoming connection on a raw listening fd.
    ///
    /// Spec-literal: takes a raw `Int32` fd. The L3-policy typed-descriptor
    /// convenience lives at swift-posix per [PLAT-ARCH-005] / [PLAT-ARCH-008e].
    ///
    /// - Parameter fd: The listening socket raw fd.
    /// - Returns: A result containing the new connected descriptor and peer address.
    /// - Throws: `ISO_9945.Kernel.Socket.Error` on failure.
    @_spi(Syscall)
    public static func accept(fd: Int32) throws(ISO_9945.Kernel.Socket.Error) -> Result {
        var storage = ISO_9945.Kernel.Socket.Address.Storage()
        var addrLen = socklen_t(ISO_9945.Kernel.Socket.Address.Storage.size.rawValue.rawValue)

        let acceptedFd = storage.withUnsafeMutableBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe Darwin_or_Glibc_accept(fd, sockaddrPtr, &addrLen)
        }

        guard acceptedFd >= 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }

        return Result(
            descriptor: acceptedFd,
            address: storage,
            length: ISO_9945.Kernel.Socket.Address.Length(addrLen)
        )
    }
}

private func Darwin_or_Glibc_accept(_ fd: Int32, _ addr: UnsafeMutablePointer<sockaddr>, _ len: UnsafeMutablePointer<socklen_t>) -> Int32 {
    #if canImport(Darwin)
        unsafe Darwin.accept(fd, addr, len)
    #elseif canImport(Glibc)
        unsafe Glibc.accept(fd, addr, len)
    #elseif canImport(Musl)
        unsafe Musl.accept(fd, addr, len)
    #endif
}
