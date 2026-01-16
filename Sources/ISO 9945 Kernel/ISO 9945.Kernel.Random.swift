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

@_spi(Syscall) public import Kernel_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

#if canImport(CLinuxShim)
    internal import CLinuxShim
#endif

// MARK: - POSIX random generation

extension ISO_9945.Kernel.Random {
    public typealias Error = Kernel.Random.Error
}

#if canImport(Darwin)

// MARK: - Darwin Implementation (arc4random_buf)

extension ISO_9945.Kernel.Random {
    /// Fills a mutable span with cryptographically secure random bytes.
    ///
    /// Uses arc4random_buf which reads from the kernel's CSPRNG.
    /// This function never fails and never blocks.
    ///
    /// - Parameter span: The mutable span to fill with random bytes.

    public static func fill(_ span: inout MutableSpan<UInt8>) {
        unsafe span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) in
            unsafe fill(buffer)
        }
    }

    /// Fills a buffer with cryptographically secure random bytes.
    ///
    /// Uses arc4random_buf which reads from the kernel's CSPRNG.
    /// This function never fails and never blocks.
    ///
    /// - Parameter buffer: The buffer to fill with random bytes.

    @unsafe
    public static func fill(_ buffer: UnsafeMutableRawBufferPointer) {
        guard let base = buffer.baseAddress, buffer.count > 0 else { return }
        unsafe arc4random_buf(base, buffer.count)
    }

    /// Fills a typed buffer with cryptographically secure random bytes.
    ///
    /// - Parameter buffer: The buffer to fill with random bytes.

    @unsafe
    public static func fill(_ buffer: UnsafeMutableBufferPointer<UInt8>) {
        unsafe fill(UnsafeMutableRawBufferPointer(buffer))
    }
}

#elseif os(Linux) || os(Android) || os(OpenBSD)

// MARK: - Linux Implementation (getrandom)

extension ISO_9945.Kernel.Random {
    /// Fills a mutable span with cryptographically secure random bytes.
    ///
    /// Uses the kernel's CSPRNG via getrandom(2). Handles partial reads
    /// and EINTR automatically by retrying until the buffer is full.
    ///
    /// - Parameter span: The mutable span to fill with random bytes.
    /// - Throws: `Error` if getrandom fails.

    public static func fill(_ span: inout MutableSpan<UInt8>) throws(Error) {
        try unsafe span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(Error) in
            try unsafe fill(buffer)
        }
    }

    /// Fills a buffer with cryptographically secure random bytes.
    ///
    /// Uses the kernel's CSPRNG via getrandom(2). Handles partial reads
    /// and EINTR automatically by retrying until the buffer is full.
    ///
    /// - Parameter buffer: The buffer to fill with random bytes.
    /// - Throws: `Error` if getrandom fails.
    @unsafe
    public static func fill(_ buffer: UnsafeMutableRawBufferPointer) throws(Error) {
        guard let base = buffer.baseAddress else { return }
        let total = buffer.count
        guard total > 0 else { return }

        var filled = 0
        while filled < total {
            let result = unsafe swift_getrandom(
                unsafe base.advanced(by: filled),
                total - filled,
                0  // No flags - blocking mode
            )

            if result > 0 {
                filled += Int(result)
                continue
            }

            if result == -1 {
                let code = Kernel.Error.Code.captureErrno()
                if code.posix == EINTR {
                    continue  // Retry on interrupt
                }
                if code.posix == EAGAIN {
                    throw .wouldBlock
                }
                throw .platform(code)
            }

            // result == 0 shouldn't happen, but treat as error
            throw .platform(.posix(0))
        }
    }

    /// Fills a typed buffer with cryptographically secure random bytes.
    ///
    /// - Parameter buffer: The buffer to fill with random bytes.
    /// - Throws: `Error` if getrandom fails.

    @unsafe
    public static func fill(_ buffer: UnsafeMutableBufferPointer<UInt8>) throws(Error) {
        try unsafe fill(UnsafeMutableRawBufferPointer(buffer))
    }
}

#endif
