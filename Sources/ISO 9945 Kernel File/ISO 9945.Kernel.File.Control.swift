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

// MARK: - POSIX fcntl() operations (raw @_spi(Syscall))

extension ISO_9945.Kernel.File.Control {
    /// Sets non-blocking mode on a raw file descriptor.
    ///
    /// Spec-literal raw `fcntl(F_GETFL)` + `fcntl(F_SETFL, flags | O_NONBLOCK)`.
    /// The typed L2 convenience
    /// (`ISO_9945.Kernel.File.Control.setNonBlocking(_:)` taking
    /// `borrowing ISO_9945.Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameter fd: The raw file descriptor to modify.
    /// - Throws: `Error` if fcntl fails.
    @_spi(Syscall)
    public static func setNonBlocking(fd: Int32) throws(ISO_9945.Kernel.File.Control.Error) {
        #if canImport(Darwin)
            let flags = unsafe Darwin.fcntl(fd, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = unsafe Darwin.fcntl(fd, F_SETFL, flags | O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #elseif canImport(Musl)
            let flags = unsafe Musl.fcntl(fd, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = unsafe Musl.fcntl(fd, F_SETFL, flags | O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #elseif canImport(Glibc)
            let flags = unsafe Glibc.fcntl(fd, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = unsafe Glibc.fcntl(fd, F_SETFL, flags | O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #endif
    }

    /// Clears non-blocking mode on a raw file descriptor.
    ///
    /// Spec-literal raw `fcntl(F_GETFL)` + `fcntl(F_SETFL, flags & ~O_NONBLOCK)`.
    /// The typed L2 convenience
    /// (`ISO_9945.Kernel.File.Control.setBlocking(_:)` taking
    /// `borrowing ISO_9945.Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameter fd: The raw file descriptor to modify.
    /// - Throws: `Error` if fcntl fails.
    @_spi(Syscall)
    public static func setBlocking(fd: Int32) throws(ISO_9945.Kernel.File.Control.Error) {
        #if canImport(Darwin)
            let flags = unsafe Darwin.fcntl(fd, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = unsafe Darwin.fcntl(fd, F_SETFL, flags & ~O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #elseif canImport(Musl)
            let flags = unsafe Musl.fcntl(fd, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = unsafe Musl.fcntl(fd, F_SETFL, flags & ~O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #elseif canImport(Glibc)
            let flags = unsafe Glibc.fcntl(fd, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = unsafe Glibc.fcntl(fd, F_SETFL, flags & ~O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #endif
    }
}

// MARK: - Typed Convenience

extension ISO_9945.Kernel.File.Control {
    /// Sets non-blocking mode on a file descriptor.
    ///
    /// Typed L2 form. Delegates to the raw `setNonBlocking(fd:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter descriptor: The file descriptor to modify.
    /// - Throws: `Error` if fcntl fails.
    public static func setNonBlocking(_ descriptor: borrowing ISO_9945.Kernel.Descriptor) throws(ISO_9945.Kernel.File.Control.Error) {
        try unsafe setNonBlocking(fd: descriptor._rawValue)
    }

    /// Clears non-blocking mode on a file descriptor.
    ///
    /// Typed L2 form. Delegates to the raw `setBlocking(fd:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// - Parameter descriptor: The file descriptor to modify.
    /// - Throws: `Error` if fcntl fails.
    public static func setBlocking(_ descriptor: borrowing ISO_9945.Kernel.Descriptor) throws(ISO_9945.Kernel.File.Control.Error) {
        try unsafe setBlocking(fd: descriptor._rawValue)
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.File.Control.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
        if let handleError = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        return .platform(Error_Primitives.Error(code: code))
    }
}
