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

// MARK: - POSIX fcntl() operations

extension ISO_9945.Kernel.File.Control {
    /// Sets non-blocking mode on a file descriptor.
    ///
    /// - Parameter descriptor: The file descriptor to modify.
    /// - Throws: `Error` if fcntl fails.
    public static func setNonBlocking(_ descriptor: borrowing Kernel.Descriptor) throws(Kernel.File.Control.Error) {
        #if canImport(Darwin)
            var flags = Darwin.fcntl(descriptor._rawValue, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = Darwin.fcntl(descriptor._rawValue, F_SETFL, flags | O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #elseif canImport(Musl)
            var flags = Musl.fcntl(descriptor._rawValue, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = Musl.fcntl(descriptor._rawValue, F_SETFL, flags | O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #elseif canImport(Glibc)
            var flags = Glibc.fcntl(descriptor._rawValue, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = Glibc.fcntl(descriptor._rawValue, F_SETFL, flags | O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #endif
    }

    /// Clears non-blocking mode on a file descriptor.
    ///
    /// - Parameter descriptor: The file descriptor to modify.
    /// - Throws: `Error` if fcntl fails.
    public static func setBlocking(_ descriptor: borrowing Kernel.Descriptor) throws(Kernel.File.Control.Error) {
        #if canImport(Darwin)
            var flags = Darwin.fcntl(descriptor._rawValue, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = Darwin.fcntl(descriptor._rawValue, F_SETFL, flags & ~O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #elseif canImport(Musl)
            var flags = Musl.fcntl(descriptor._rawValue, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = Musl.fcntl(descriptor._rawValue, F_SETFL, flags & ~O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #elseif canImport(Glibc)
            var flags = Glibc.fcntl(descriptor._rawValue, F_GETFL)
            guard flags >= 0 else {
                throw Error.current()
            }
            let result = Glibc.fcntl(descriptor._rawValue, F_SETFL, flags & ~O_NONBLOCK)
            guard result >= 0 else {
                throw Error.current()
            }
        #endif
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.File.Control.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Kernel.Error.Code.current()
        if let handleError = Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        if let ioError = Kernel.IO.Error(code: code) {
            return .io(ioError)
        }
        return .platform(Kernel.Error(code: code))
    }
}
