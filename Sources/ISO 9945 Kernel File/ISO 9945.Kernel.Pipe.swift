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

// MARK: - POSIX pipe() syscall

extension ISO_9945.Kernel.Pipe {
    /// The result of creating a pipe, containing read and write descriptors.
    public typealias Descriptors = Tagged<Kernel.Pipe, Pair<Kernel.Descriptor, Kernel.Descriptor>>
}

extension Tagged where Tag == Kernel.Pipe, RawValue == Pair<Kernel.Descriptor, Kernel.Descriptor> {
    /// The read end of the pipe.
    public var read: Kernel.Descriptor {
        @inlinable _read { yield rawValue.first }
    }

    /// The write end of the pipe.
    public var write: Kernel.Descriptor {
        @inlinable _read { yield rawValue.second }
    }

    /// Creates pipe descriptors from read and write ends.
    @inlinable
    internal init(read: consuming Kernel.Descriptor, write: consuming Kernel.Descriptor) {
        self.init(__unchecked: (), Pair(read, write))
    }
}

extension ISO_9945.Kernel.Pipe {

    /// Creates an anonymous pipe.
    ///
    /// Returns a pair of file descriptors: `read` for the read end and `write`
    /// for the write end. Data written to the write end is buffered by the
    /// kernel until read from the read end.
    ///
    /// - Returns: The read and write descriptors for the pipe.
    /// - Throws: `Kernel.Pipe.Error` on failure.
    public static func pipe() throws(Error) -> Descriptors {
        var fds: (Int32, Int32) = (0, 0)

        let result = unsafe withUnsafeMutablePointer(to: &fds) { ptr in
            unsafe ptr.withMemoryRebound(to: Int32.self, capacity: 2) { fdPtr in
                #if canImport(Darwin)
                    unsafe Darwin.pipe(fdPtr)
                #elseif canImport(Musl)
                    Musl.pipe(fdPtr)
                #elseif canImport(Glibc)
                    Glibc.pipe(fdPtr)
                #endif
            }
        }

        guard result == 0 else {
            throw Error.current()
        }

        return Descriptors(
            read: Kernel.Descriptor(_rawValue: fds.0),
            write: Kernel.Descriptor(_rawValue: fds.1)
        )
    }

}

// MARK: - Error Alias

extension ISO_9945.Kernel.Pipe {
    public typealias Error = Kernel.Pipe.Error
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.Pipe.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let e = errno
        let code = Kernel.Error.Code.posix(e)
        if let handleError = Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        return .platform(Kernel.Error(code: code))
    }
}
