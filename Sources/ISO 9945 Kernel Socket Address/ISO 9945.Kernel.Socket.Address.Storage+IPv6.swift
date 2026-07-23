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

extension ISO_9945.Kernel.Socket.Address.Storage {
    /// The typed IPv6 form, when the stored family is `.inet6`.
    ///
    /// Inverse of ``ISO_9945/Kernel/Socket/Address/IPv6/storage``; returns nil
    /// for every other family.
    public var ipv6: ISO_9945.Kernel.Socket.Address.IPv6? {
        guard family == .inet6 else { return nil }
        var result = ISO_9945.Kernel.Socket.Address.IPv6()
        unsafe withUnsafeBytes { source, capacity in
            unsafe Swift.withUnsafeMutableBytes(of: &result.cValue) { destination in
                let count = min(MemoryLayout<sockaddr_in6>.size, Int(capacity))
                unsafe destination.copyMemory(
                    from: UnsafeRawBufferPointer(start: source, count: count)
                )
            }
        }
        return result
    }
}
