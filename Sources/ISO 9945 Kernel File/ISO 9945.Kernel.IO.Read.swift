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

@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_File_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX read() syscall (raw @_spi(Syscall))

extension ISO_9945.Kernel.IO.Read {
    /// Reads bytes from a raw file descriptor.
    ///
    /// Spec-literal raw `read(2)`. The typed L2 convenience
    /// (`ISO_9945.Kernel.IO.Read.read(_:into:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameters:
    ///   - fd: The raw file descriptor to read from.
    ///   - buffer: The buffer to read into.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    @_spi(Syscall)
    public static func read(
        fd: Int32,
        into buffer: UnsafeMutableRawBufferPointer
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }
        #if canImport(Darwin)
            return try Kernel.Syscall.require(
                unsafe Darwin.read(fd, baseAddress, buffer.count),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif canImport(Musl)
            return try Kernel.Syscall.require(
                unsafe Musl.read(fd, baseAddress, buffer.count),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif canImport(Glibc)
            return try Kernel.Syscall.require(
                unsafe Glibc.read(fd, baseAddress, buffer.count),
                .nonNegative,
                orThrow: Error.current()
            )
        #endif
    }

    /// Reads bytes from a raw file descriptor at a specific offset.
    ///
    /// Spec-literal raw `pread(2)`. The typed L2 convenience
    /// (`ISO_9945.Kernel.IO.Read.pread(_:into:at:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameters:
    ///   - fd: The raw file descriptor to read from.
    ///   - buffer: The buffer to read into.
    ///   - offset: The file offset to read from.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    @_spi(Syscall)
    public static func pread(
        fd: Int32,
        into buffer: UnsafeMutableRawBufferPointer,
        at offset: Kernel.File.Offset
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }
        #if canImport(Darwin)
            return try Kernel.Syscall.require(
                unsafe Darwin.pread(fd, baseAddress, buffer.count, off_t(offset.rawValue)),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif canImport(Musl)
            return try Kernel.Syscall.require(
                unsafe Musl.pread(fd, baseAddress, buffer.count, off_t(offset.rawValue)),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif canImport(Glibc)
            return try Kernel.Syscall.require(
                unsafe Glibc.pread(fd, baseAddress, buffer.count, off_t(offset.rawValue)),
                .nonNegative,
                orThrow: Error.current()
            )
        #endif
    }
}

// MARK: - Typed Convenience

extension ISO_9945.Kernel.IO.Read {
    /// Reads bytes from a file descriptor.
    ///
    /// Typed L2 form. Delegates to the raw `read(fd:into:)` SPI via
    /// `descriptor._rawValue` after a fast-fail validity check.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to read from.
    ///   - buffer: The buffer to read into.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    public static func read(
        _ descriptor: borrowing Kernel.Descriptor,
        into buffer: UnsafeMutableRawBufferPointer
    ) throws(Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        return try unsafe read(fd: descriptor._rawValue, into: buffer)
    }

    /// Reads bytes from a file descriptor at a specific offset.
    ///
    /// Typed L2 form. Delegates to the raw `pread(fd:into:at:)` SPI via
    /// `descriptor._rawValue` after a fast-fail validity check.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to read from.
    ///   - buffer: The buffer to read into.
    ///   - offset: The file offset to read from.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    public static func pread(
        _ descriptor: borrowing Kernel.Descriptor,
        into buffer: UnsafeMutableRawBufferPointer,
        at offset: Kernel.File.Offset
    ) throws(Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        return try unsafe pread(fd: descriptor._rawValue, into: buffer, at: offset)
    }
}

// MARK: - Span Adapters

extension ISO_9945.Kernel.IO.Read {
    /// Reads bytes from a file descriptor into a mutable span.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to read from.
    ///   - span: The mutable span to read into.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    public static func read(
        _ descriptor: borrowing Kernel.Descriptor,
        into span: inout MutableSpan<UInt8>
    ) throws(Error) -> Int {
        try unsafe span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(Error) -> Int in
            try unsafe read(descriptor, into: buffer)
        }
    }

    /// Reads bytes from a file descriptor at a specific offset into a mutable span.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to read from.
    ///   - span: The mutable span to read into.
    ///   - offset: The file offset to read from.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    public static func pread(
        _ descriptor: borrowing Kernel.Descriptor,
        into span: inout MutableSpan<UInt8>,
        at offset: Kernel.File.Offset
    ) throws(Error) -> Int {
        try unsafe span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(Error) -> Int in
            try unsafe pread(descriptor, into: buffer, at: offset)
        }
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.IO.Read.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Kernel.Error.Code.current()
        if let handleError = Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        if let blockingError = Kernel.IO.Blocking.Error(code: code) {
            return .blocking(blockingError)
        }
        if let ioError = Kernel.IO.Error(code: code) {
            return .io(ioError)
        }
        if let memoryError = Kernel.Memory.Error(code: code) {
            return .memory(memoryError)
        }
        return .platform(Kernel.Error(code: code))
    }
}
