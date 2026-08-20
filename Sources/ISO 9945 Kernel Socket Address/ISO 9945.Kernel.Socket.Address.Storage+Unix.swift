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
    /// The typed Unix-domain form, when the stored family is `.unix`.
    ///
    /// Inverse of ``ISO_9945/Kernel/Socket/Address/Unix/storage``; returns nil
    /// for every other family.
    public var unix: ISO_9945.Kernel.Socket.Address.Unix? {
        guard family == .unix else { return nil }
        var result = ISO_9945.Kernel.Socket.Address.Unix()
        unsafe withUnsafeBytes { source, capacity in
            Swift.withUnsafeMutableBytes(of: &result.cValue) { destination in
                let count = min(MemoryLayout<sockaddr_un>.size, Int(capacity))
                unsafe destination.copyMemory(
                    from: UnsafeRawBufferPointer(start: source, count: count)
                )
            }
        }
        return result
    }
}
