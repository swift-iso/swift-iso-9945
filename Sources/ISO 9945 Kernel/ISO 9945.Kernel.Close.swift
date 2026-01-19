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

// MARK: - POSIX close() syscall

extension ISO_9945.Kernel.Close {
    /// Closes a file descriptor, releasing the associated kernel resource.
    ///
    /// ## Threading
    /// This call blocks until the close completes. On most systems, close is fast,
    /// but may block on NFS or other networked filesystems while flushing data.
    ///
    /// ## Descriptor Invalidation
    /// After a successful close, the descriptor becomes invalid. Passing a closed
    /// descriptor to any operation is undefined behavior—the kernel may have
    /// reassigned the descriptor number to a new resource.
    ///
    /// ## Errors
    /// - ``Error/handle(_:)``: The descriptor is invalid (`.invalid`)
    /// - ``Error/io(_:)``: An I/O error occurred during close (data may be lost)
    /// - ``Error/interrupted``: Close was interrupted by a signal (descriptor state undefined on some platforms)
    ///
    /// - Parameter descriptor: The file descriptor to close.
    /// - Throws: ``Kernel/Close/Error`` on failure.
    public static func close(_ descriptor: Kernel.Descriptor) throws(Kernel.Close.Error) {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        #if canImport(Darwin)
            try Kernel.Syscall.require(unsafe Darwin.close(descriptor._rawValue), .equals(0), orThrow: Error.current())
        #elseif canImport(Glibc)
            try Kernel.Syscall.require(unsafe Glibc.close(descriptor._rawValue), .equals(0), orThrow: Error.current())
        #elseif canImport(Musl)
            try Kernel.Syscall.require(unsafe Musl.close(descriptor._rawValue), .equals(0), orThrow: Error.current())
        #endif
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.Close.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let e = errno
        let code = Kernel.Error.Code.posix(e)
        if let handleError = Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        if let ioError = Kernel.IO.Error(code: code) {
            return .io(ioError)
        }
        return .platform(Kernel.Error(code: code))
    }
}
