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
    /// ## Threading
    /// This call blocks until at least one byte is written or an error occurs.
    /// The file offset is advanced by the number of bytes written. Concurrent
    /// sequential writes require external synchronization.
    ///
    /// ## Partial Writes
    /// May return fewer bytes than `buffer.count`. This is not an error—loop until
    /// all data is written. Returns 0 only for zero-length buffers.
    ///
    /// ## Errors
    /// - ``Error/handle(_:)``: Invalid descriptor
    /// - ``Error/io(_:)``: Physical I/O error
    /// - ``Error/noSpace``: Filesystem full
    /// - ``Error/pipe``: Write to pipe/socket with no readers (also raises SIGPIPE)
    /// - ``Error/wouldBlock``: Non-blocking descriptor would block
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - buffer: The buffer to write from.
    /// - Returns: Number of bytes written (may be less than `buffer.count`).
    /// - Throws: ``Kernel/IO/Write/Error`` on failure.
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
            return try Kernel.Syscall.require(
                unsafe Darwin.write(descriptor._rawValue, baseAddress, buffer.count),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif canImport(Musl)
            return try Kernel.Syscall.require(
                unsafe Musl.write(descriptor._rawValue, baseAddress, buffer.count),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif canImport(Glibc)
            return try Kernel.Syscall.require(
                unsafe Glibc.write(descriptor._rawValue, baseAddress, buffer.count),
                .nonNegative,
                orThrow: Error.current()
            )
        #endif
    }

    /// Writes bytes to a file descriptor at a specific offset without changing the file position.
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
    /// ## Errors
    /// - ``Error/handle(_:)``: Invalid descriptor
    /// - ``Error/io(_:)``: Physical I/O error
    /// - ``Error/noSpace``: Filesystem full
    /// - ``Error/invalidSeek``: Descriptor does not support seeking (pipes, sockets)
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to write to.
    ///   - buffer: The buffer to write from.
    ///   - offset: The file offset to write at.
    /// - Returns: Number of bytes written (may be less than `buffer.count`).
    /// - Throws: ``Kernel/IO/Write/Error`` on failure.
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
            return try Kernel.Syscall.require(
                unsafe Darwin.pwrite(descriptor._rawValue, baseAddress, buffer.count, off_t(offset.rawValue)),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif canImport(Musl)
            return try Kernel.Syscall.require(
                unsafe Musl.pwrite(descriptor._rawValue, baseAddress, buffer.count, off_t(offset.rawValue)),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif canImport(Glibc)
            return try Kernel.Syscall.require(
                unsafe Glibc.pwrite(descriptor._rawValue, baseAddress, buffer.count, off_t(offset.rawValue)),
                .nonNegative,
                orThrow: Error.current()
            )
        #endif
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
        try span.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(Error) -> Int in
            try write(descriptor, from: buffer)
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
        try span.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(Error) -> Int in
            try pwrite(descriptor, from: buffer, at: offset)
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
