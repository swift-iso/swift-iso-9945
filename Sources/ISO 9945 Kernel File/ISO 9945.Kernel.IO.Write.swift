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

@_spi(Syscall) import ISO_9945_Core


#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX write() syscall (raw @_spi(Syscall))

extension ISO_9945.Kernel.IO.Write {
    /// Writes bytes to a raw file descriptor at the current file offset.
    ///
    /// This is the raw POSIX `write(2)` syscall. It does NOT automatically retry
    /// on EINTR — callers must handle signal interruption explicitly. For automatic
    /// EINTR retry, use the policy-aware wrapper in `POSIX_Kernel`. The typed L2
    /// convenience (`ISO_9945.Kernel.IO.Write.write(_:from:)` taking
    /// `borrowing ISO_9945.Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// ## Threading
    /// This call blocks until at least one byte is written or an error occurs.
    /// The file offset is advanced by the number of bytes written. Concurrent
    /// sequential writes require external synchronization.
    ///
    /// ## Partial Writes
    /// May return fewer bytes than `buffer.count`. This is not an error — loop until
    /// all data is written. Returns 0 only for zero-length buffers.
    ///
    /// ## EINTR
    /// This function does NOT retry on EINTR. On signal interruption, throws
    /// `.platform(Error_Primitives.Error(code: .posix(EINTR)))`. Callers should check
    /// `error.code.isInterrupted` and retry if appropriate.
    ///
    /// - Parameters:
    ///   - fd: The raw file descriptor to write to.
    ///   - buffer: The buffer to write from.
    /// - Returns: Number of bytes written (may be less than `buffer.count`).
    /// - Throws: ``Kernel/IO/Write/Error`` on failure (including EINTR).
    internal static func write(
        fd: Int32,
        from buffer: UnsafeRawBufferPointer
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }

        #if canImport(Darwin)
            let result = unsafe Darwin.write(fd, baseAddress, buffer.count)
        #elseif canImport(Musl)
            let result = unsafe Musl.write(fd, baseAddress, buffer.count)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.write(fd, baseAddress, buffer.count)
        #endif

        if result >= 0 {
            return result
        }

        throw Error.current()
    }

    /// Writes bytes to a raw file descriptor at a specific offset without changing the file position.
    ///
    /// This is the raw POSIX `pwrite(2)` syscall. It does NOT automatically retry
    /// on EINTR — callers must handle signal interruption explicitly. For automatic
    /// EINTR retry, use the policy-aware wrapper in `POSIX_Kernel`. The typed L2
    /// convenience (`ISO_9945.Kernel.IO.Write.pwrite(_:from:at:)` taking
    /// `borrowing ISO_9945.Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// ## Threading
    /// This call blocks until at least one byte is written or an error occurs.
    /// The file offset is **not** modified. Safe for concurrent use from multiple
    /// threads when writing to non-overlapping regions.
    ///
    /// ## Partial Writes
    /// May return fewer bytes than `buffer.count`. This is not an error — loop until
    /// all data is written, adjusting the offset accordingly.
    ///
    /// ## EINTR
    /// This function does NOT retry on EINTR. On signal interruption, throws
    /// `.platform(Error_Primitives.Error(code: .posix(EINTR)))`. Callers should check
    /// `error.code.isInterrupted` and retry if appropriate.
    ///
    /// - Parameters:
    ///   - fd: The raw file descriptor to write to.
    ///   - buffer: The buffer to write from.
    ///   - offset: The file offset to write at.
    /// - Returns: Number of bytes written (may be less than `buffer.count`).
    /// - Throws: ``Kernel/IO/Write/Error`` on failure (including EINTR).
    internal static func pwrite(
        fd: Int32,
        from buffer: UnsafeRawBufferPointer,
        at offset: ISO_9945.Kernel.File.Offset
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }

        #if canImport(Darwin)
            let result = unsafe Darwin.pwrite(fd, baseAddress, buffer.count, off_t(offset.underlying))
        #elseif canImport(Musl)
            let result = unsafe Musl.pwrite(fd, baseAddress, buffer.count, off_t(offset.underlying))
        #elseif canImport(Glibc)
            let result = unsafe Glibc.pwrite(fd, baseAddress, buffer.count, off_t(offset.underlying))
        #endif

        if result >= 0 {
            return result
        }

        throw Error.current()
    }
}

// MARK: - Typed Convenience

extension ISO_9945.Kernel.IO.Write {
    /// Writes bytes to a file descriptor at the current file offset.
    ///
    /// Typed L2 form. Delegates to the raw `write(fd:from:)` SPI via
    /// `descriptor._rawValue` after a fast-fail validity check. Marked
    /// `@_disfavoredOverload` so the L3-unifier `ISO_9945.Kernel.IO.Write.write(_:from:)`
    /// (EINTR-retry policy) wins overload resolution at consumer sites that
    /// see both layers — raw spec access is reachable via this L2 form.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - buffer: The buffer to write from.
    /// - Returns: Number of bytes written (may be less than `buffer.count`).
    /// - Throws: ``Kernel/IO/Write/Error`` on failure (including EINTR).
    @_disfavoredOverload
    public static func write(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        from buffer: UnsafeRawBufferPointer
    ) throws(Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        return try unsafe write(fd: descriptor._rawValue, from: buffer)
    }

    /// Writes bytes to a file descriptor at a specific offset without changing the file position.
    ///
    /// Typed L2 form. Delegates to the raw `pwrite(fd:from:at:)` SPI via
    /// `descriptor._rawValue` after a fast-fail validity check. Marked
    /// `@_disfavoredOverload` so the L3-unifier
    /// `ISO_9945.Kernel.IO.Write.pwrite(_:from:at:)` (EINTR-retry policy) wins overload
    /// resolution.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - buffer: The buffer to write from.
    ///   - offset: The file offset to write at.
    /// - Returns: Number of bytes written (may be less than `buffer.count`).
    /// - Throws: ``Kernel/IO/Write/Error`` on failure (including EINTR).
    @_disfavoredOverload
    public static func pwrite(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        from buffer: UnsafeRawBufferPointer,
        at offset: ISO_9945.Kernel.File.Offset
    ) throws(Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        return try unsafe pwrite(fd: descriptor._rawValue, from: buffer, at: offset)
    }
}

// MARK: - Span Adapters

extension ISO_9945.Kernel.IO.Write {
    /// Writes bytes from a span to a file descriptor.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - span: The span containing bytes to write.
    /// - Returns: Number of bytes written.
    /// - Throws: `ISO_9945.Kernel.IO.Write.Error` on failure.
    @_disfavoredOverload
    public static func write(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        from span: Span<UInt8>
    ) throws(Error) -> Int {
        try unsafe span.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(Error) -> Int in
            try unsafe write(descriptor, from: buffer)
        }
    }

    /// Writes bytes from a span to a file descriptor at a specific offset.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - span: The span containing bytes to write.
    ///   - offset: The file offset to write at.
    /// - Returns: Number of bytes written.
    /// - Throws: `ISO_9945.Kernel.IO.Write.Error` on failure.
    @_disfavoredOverload
    public static func pwrite(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        from span: Span<UInt8>,
        at offset: ISO_9945.Kernel.File.Offset
    ) throws(Error) -> Int {
        try unsafe span.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(Error) -> Int in
            try unsafe pwrite(descriptor, from: buffer, at: offset)
        }
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.IO.Write.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
        if let handleError = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        if let blockingError = ISO_9945.Kernel.IO.Blocking.Error(code: code) {
            return .blocking(blockingError)
        }
        return .platform(Error_Primitives.Error(code: code))
    }
}
