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

// MARK: - POSIX pipe() syscall

extension ISO_9945.Kernel.Pipe {
    /// The result of creating a pipe, containing read and write descriptors.
    public typealias Descriptors = Tagged<ISO_9945.Kernel.Pipe, Pair<ISO_9945.Kernel.Descriptor, ISO_9945.Kernel.Descriptor>>
}

extension Tagged where Tag == ISO_9945.Kernel.Pipe, Underlying == Pair<ISO_9945.Kernel.Descriptor, ISO_9945.Kernel.Descriptor> {
    /// The read end of the pipe.
    public var read: ISO_9945.Kernel.Descriptor {
        @inlinable _read { yield underlying.first }
    }

    /// The write end of the pipe.
    public var write: ISO_9945.Kernel.Descriptor {
        @inlinable _read { yield underlying.second }
    }

    /// Creates pipe descriptors from read and write ends.
    @inlinable
    internal init(read: consuming ISO_9945.Kernel.Descriptor, write: consuming ISO_9945.Kernel.Descriptor) {
        self.init(_unchecked: Pair(read, write))
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
    /// - Throws: `ISO_9945.Kernel.Pipe.Error` on failure.
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
            read: ISO_9945.Kernel.Descriptor(_rawValue: fds.0),
            write: ISO_9945.Kernel.Descriptor(_rawValue: fds.1)
        )
    }

}

// MARK: - Error Alias

extension ISO_9945.Kernel.Pipe {
    public typealias Error = ISO_9945.Kernel.Pipe.Error
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.Pipe.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
        if let handleError = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        return .platform(Error_Primitives.Error(code: code))
    }
}
