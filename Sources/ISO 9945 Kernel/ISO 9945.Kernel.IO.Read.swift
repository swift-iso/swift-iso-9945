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

// MARK: - POSIX read() syscall

extension ISO_9945.Kernel.IO.Read {
    /// Reads bytes from a file descriptor.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to read from.
    ///   - buffer: The buffer to read into.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    public static func read(
        _ descriptor: Kernel.Descriptor,
        into buffer: UnsafeMutableRawBufferPointer
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        #if canImport(Darwin)
            return try Kernel.Syscall.require(
                unsafe Darwin.read(descriptor._rawValue, baseAddress, buffer.count),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif canImport(Musl)
            return try Kernel.Syscall.require(
                unsafe Musl.read(descriptor._rawValue, baseAddress, buffer.count),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif canImport(Glibc)
            return try Kernel.Syscall.require(
                unsafe Glibc.read(descriptor._rawValue, baseAddress, buffer.count),
                .nonNegative,
                orThrow: Error.current()
            )
        #endif
    }

    /// Reads bytes from a file descriptor at a specific offset.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to read from.
    ///   - buffer: The buffer to read into.
    ///   - offset: The file offset to read from.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    public static func pread(
        _ descriptor: Kernel.Descriptor,
        into buffer: UnsafeMutableRawBufferPointer,
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
                unsafe Darwin.pread(descriptor._rawValue, baseAddress, buffer.count, off_t(offset.rawValue)),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif canImport(Musl)
            return try Kernel.Syscall.require(
                unsafe Musl.pread(descriptor._rawValue, baseAddress, buffer.count, off_t(offset.rawValue)),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif canImport(Glibc)
            return try Kernel.Syscall.require(
                unsafe Glibc.pread(descriptor._rawValue, baseAddress, buffer.count, off_t(offset.rawValue)),
                .nonNegative,
                orThrow: Error.current()
            )
        #endif
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
        _ descriptor: Kernel.Descriptor,
        into span: inout MutableSpan<UInt8>
    ) throws(Error) -> Int {
        try span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(Error) -> Int in
            try read(descriptor, into: buffer)
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
        _ descriptor: Kernel.Descriptor,
        into span: inout MutableSpan<UInt8>,
        at offset: Kernel.File.Offset
    ) throws(Error) -> Int {
        try span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(Error) -> Int in
            try pread(descriptor, into: buffer, at: offset)
        }
    }
}

// MARK: - Error Conversion

extension Kernel.IO.Read.Error {
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
        if let memoryError = Kernel.Memory.Error(code: code) {
            return .memory(memoryError)
        }
        return .platform(Kernel.Error(code: code))
    }
}
