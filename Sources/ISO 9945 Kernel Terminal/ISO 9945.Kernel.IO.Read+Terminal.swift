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

/// Terminal.Stream overloads for Kernel.IO.Read.
///
/// Standard streams (stdin/stdout/stderr) are process-owned file descriptors
/// that cannot be wrapped in `Kernel.Descriptor` without claiming ownership
/// (which would close them on deinit). These overloads accept `Terminal.Stream`
/// directly, performing the raw fd extraction at the C boundary per [IMPL-010].

#if !os(Windows)

@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_File_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.IO.Read {
    /// Reads bytes from a terminal stream.
    ///
    /// - Parameters:
    ///   - stream: The terminal stream to read from.
    ///   - buffer: The buffer to read into.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    public static func read(
        _ stream: Terminal.Stream,
        into buffer: UnsafeMutableRawBufferPointer
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }
        #if canImport(Darwin)
            return try Kernel.Syscall.require(
                unsafe Darwin.read(stream.rawValue, baseAddress, buffer.count),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif canImport(Musl)
            return try Kernel.Syscall.require(
                unsafe Musl.read(stream.rawValue, baseAddress, buffer.count),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif canImport(Glibc)
            return try Kernel.Syscall.require(
                unsafe Glibc.read(stream.rawValue, baseAddress, buffer.count),
                .nonNegative,
                orThrow: Error.current()
            )
        #endif
    }
}

#endif
