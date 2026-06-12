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

@_spi(Syscall) public import ISO_9945_Core

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

// MARK: - Accept typed (Phase 1.5)
//
// Typed Phase-1.5 form re-added in Wave 4c-Socket Main (2026-05-01) per
// [PLAT-ARCH-005] three-tier chain (Prerequisite II). Result carries the
// accepted descriptor typed at birth (2026-06-12): the syscall layer is
// the ownership boundary, so the raw fd is wrapped into the move-only
// Descriptor here — a dropped Result closes the accepted connection via
// Descriptor deinit instead of leaking the fd.

extension ISO_9945.Kernel.Socket.Accept {
    /// Accepts an incoming connection on a typed listening descriptor.
    public static func accept(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor
    ) throws(ISO_9945.Kernel.Socket.Error) -> Result {
        try accept(fd: descriptor._rawValue)
    }
}

// MARK: - Accept raw fd SPI

extension ISO_9945.Kernel.Socket.Accept {
    /// Accepts an incoming connection on a raw listening fd.
    ///
    /// Spec-literal: takes a raw `Int32` fd. The L3-policy typed-descriptor
    /// convenience lives at swift-posix per [PLAT-ARCH-005] / [PLAT-ARCH-008e].
    ///
    /// - Parameter fd: The listening socket raw fd.
    /// - Returns: A result containing the new connected descriptor and peer address.
    /// - Throws: `ISO_9945.Kernel.Socket.Error` on failure.
    internal static func accept(fd: Int32) throws(ISO_9945.Kernel.Socket.Error) -> Result {
        var storage = ISO_9945.Kernel.Socket.Address.Storage()
        var addrLen = socklen_t(ISO_9945.Kernel.Socket.Address.Storage.size.underlying.rawValue)

        let acceptedFd = storage.withUnsafeMutableBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe Darwin_or_Glibc_accept(fd, sockaddrPtr, &addrLen)
        }

        guard acceptedFd >= 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }

        return Result(
            descriptor: ISO_9945.Kernel.Socket.Descriptor(_raw: acceptedFd),
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
