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

// MARK: - POSIX write() syscall

extension ISO_9945.Kernel.IO.Write {
    /// Writes bytes to a file descriptor at the current file offset.
    ///
    /// This is the raw POSIX `write(2)` syscall. It does NOT automatically retry
    /// on EINTR - callers must handle signal interruption explicitly. For automatic
    /// EINTR retry, use the policy-aware wrapper in `POSIX_Kernel`.
    ///
    /// ## Threading
    /// This call blocks until at least one byte is written or an error occurs.
    /// The file offset is advanced by the number of bytes written. Concurrent
    /// sequential writes require external synchronization.
    ///
    /// ## Partial Writes
    /// May return fewer bytes than `buffer.count`. This is not an error—loop until
    /// all data is written. Returns 0 only for zero-length buffers.
    ///
    /// ## EINTR
    /// This function does NOT retry on EINTR. On signal interruption, throws
    /// `.platform(Kernel.Error(code: .posix(EINTR)))`. Callers should check
    /// `error.isInterrupted` and retry if appropriate.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - buffer: The buffer to write from.
    /// - Returns: Number of bytes written (may be less than `buffer.count`).
    /// - Throws: ``Kernel/IO/Write/Error`` on failure (including EINTR).
    public static func write(
        _ descriptor: Kernel.Descriptor,
        from buffer: UnsafeRawBufferPointer
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }

        #if canImport(Darwin)
            let result = unsafe Darwin.write(descriptor._rawValue, baseAddress, buffer.count)
        #elseif canImport(Musl)
            let result = unsafe Musl.write(descriptor._rawValue, baseAddress, buffer.count)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.write(descriptor._rawValue, baseAddress, buffer.count)
        #endif

        if result >= 0 {
            return result
        }

        throw Error.current()
    }

    /// Writes bytes to a file descriptor at a specific offset without changing the file position.
    ///
    /// This is the raw POSIX `pwrite(2)` syscall. It does NOT automatically retry
    /// on EINTR - callers must handle signal interruption explicitly. For automatic
    /// EINTR retry, use the policy-aware wrapper in `POSIX_Kernel`.
    ///
    /// ## Threading
    /// This call blocks until at least one byte is written or an error occurs.
    /// The file offset is **not** modified. Safe for concurrent use from multiple
    /// threads when writing to non-overlapping regions.
    ///
    /// ## Partial Writes
    /// May return fewer bytes than `buffer.count`. This is not an error—loop until
    /// all data is written, adjusting the offset accordingly.
    ///
    /// ## EINTR
    /// This function does NOT retry on EINTR. On signal interruption, throws
    /// `.platform(Kernel.Error(code: .posix(EINTR)))`. Callers should check
    /// `error.isInterrupted` and retry if appropriate.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - buffer: The buffer to write from.
    ///   - offset: The file offset to write at.
    /// - Returns: Number of bytes written (may be less than `buffer.count`).
    /// - Throws: ``Kernel/IO/Write/Error`` on failure (including EINTR).
    public static func pwrite(
        _ descriptor: Kernel.Descriptor,
        from buffer: UnsafeRawBufferPointer,
        at offset: Kernel.File.Offset
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }

        #if canImport(Darwin)
            let result = unsafe Darwin.pwrite(descriptor._rawValue, baseAddress, buffer.count, off_t(offset.rawValue))
        #elseif canImport(Musl)
            let result = unsafe Musl.pwrite(descriptor._rawValue, baseAddress, buffer.count, off_t(offset.rawValue))
        #elseif canImport(Glibc)
            let result = unsafe Glibc.pwrite(descriptor._rawValue, baseAddress, buffer.count, off_t(offset.rawValue))
        #endif

        if result >= 0 {
            return result
        }

        throw Error.current()
    }
}

// MARK: - Write All

extension ISO_9945.Kernel.IO.Write {
    /// Writes all bytes to a file descriptor, handling partial writes and EINTR.
    ///
    /// This function loops until all bytes are written or an error occurs.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - buffer: The buffer to write from.
    /// - Throws: ``Kernel/IO/Write/Error`` on failure.
    public static func writeAll(
        _ descriptor: Kernel.Descriptor,
        from buffer: UnsafeRawBufferPointer
    ) throws(Error) {
        guard let baseAddress = buffer.baseAddress else {
            return
        }

        var written = 0
        let total = buffer.count

        while written < total {
            let remaining = unsafe UnsafeRawBufferPointer(
                start: baseAddress.advanced(by: written),
                count: total - written
            )
            let n = try unsafe write(descriptor, from: remaining)
            if n == 0 {
                // Should not happen for regular files, but handle gracefully
                throw .io(.hardware)
            }
            written += n
        }
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
    /// - Throws: `Kernel.IO.Write.Error` on failure.

    public static func write(
        _ descriptor: Kernel.Descriptor,
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
    /// - Throws: `Kernel.IO.Write.Error` on failure.

    public static func pwrite(
        _ descriptor: Kernel.Descriptor,
        from span: Span<UInt8>,
        at offset: Kernel.File.Offset
    ) throws(Error) -> Int {
        try unsafe span.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(Error) -> Int in
            try unsafe pwrite(descriptor, from: buffer, at: offset)
        }
    }

    /// Writes all bytes from a span to a file descriptor.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - span: The span containing bytes to write.
    /// - Throws: `Kernel.IO.Write.Error` on failure.

    public static func writeAll(
        _ descriptor: Kernel.Descriptor,
        from span: Span<UInt8>
    ) throws(Error) {
        try unsafe span.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(Error) in
            try unsafe writeAll(descriptor, from: buffer)
        }
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.IO.Write.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let e = errno
        let code = Kernel.Error.Code.posix(e)
        if let handleError = Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        if let blockingError = Kernel.IO.Blocking.Error(code: code) {
            return .blocking(blockingError)
        }
        if let ioError = Kernel.IO.Error(code: code) {
            return .io(ioError)
        }
        if let spaceError = Kernel.Storage.Error(code: code) {
            return .space(spaceError)
        }
        if let memoryError = Kernel.Memory.Error(code: code) {
            return .memory(memoryError)
        }
        return .platform(Kernel.Error(code: code))
    }
}
