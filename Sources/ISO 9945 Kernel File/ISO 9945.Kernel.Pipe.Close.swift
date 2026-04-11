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

// MARK: - Pipe descriptor split operations

extension ISO_9945.Kernel.Pipe {
    /// Operations that close one end of a pipe, returning the other.
    public enum Close: Sendable {}
}

extension ISO_9945.Kernel.Pipe.Close {
    /// Closes the write end of a pipe, returning the read end.
    ///
    /// Consumes the pipe descriptors. The write-end descriptor is closed
    /// via `close(2)`; the read-end descriptor is returned with ownership
    /// transferred to the caller.
    ///
    /// - Parameter descriptors: The pipe descriptors (consumed).
    /// - Returns: The read-end descriptor.
    /// - Throws: `Kernel.Close.Error` if closing the write end fails.
    ///   On error, the read end is also closed (via deinit).
    public static func write(
        _ descriptors: consuming Kernel.Pipe.Descriptors
    ) throws(Kernel.Close.Error) -> Kernel.Descriptor {
        let tagged = try descriptors.map { (pair: consuming Pair<Kernel.Descriptor, Kernel.Descriptor>) throws(Kernel.Close.Error) -> Kernel.Descriptor in
            try pair.apply { (read: consuming Kernel.Descriptor, write: consuming Kernel.Descriptor) throws(Kernel.Close.Error) -> Kernel.Descriptor in
                try Kernel.Close.close(write)
                return read
            }
        }
        return tagged.rawValue
    }

    /// Closes the read end of a pipe, returning the write end.
    ///
    /// Consumes the pipe descriptors. The read-end descriptor is closed
    /// via `close(2)`; the write-end descriptor is returned with ownership
    /// transferred to the caller.
    ///
    /// - Parameter descriptors: The pipe descriptors (consumed).
    /// - Returns: The write-end descriptor.
    /// - Throws: `Kernel.Close.Error` if closing the read end fails.
    ///   On error, the write end is also closed (via deinit).
    public static func read(
        _ descriptors: consuming Kernel.Pipe.Descriptors
    ) throws(Kernel.Close.Error) -> Kernel.Descriptor {
        let tagged = try descriptors.map { (pair: consuming Pair<Kernel.Descriptor, Kernel.Descriptor>) throws(Kernel.Close.Error) -> Kernel.Descriptor in
            try pair.apply { (read: consuming Kernel.Descriptor, write: consuming Kernel.Descriptor) throws(Kernel.Close.Error) -> Kernel.Descriptor in
                try Kernel.Close.close(read)
                return write
            }
        }
        return tagged.rawValue
    }
}
