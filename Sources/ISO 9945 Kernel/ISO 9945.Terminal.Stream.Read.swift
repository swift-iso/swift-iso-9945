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

/// POSIX implementation of Terminal stream read operations.

#if !os(Windows)

@_spi(Syscall) public import Kernel_Primitives
public import Terminal_Primitives

extension Terminal.Stream.Read {
    /// Read bytes from this terminal stream.
    ///
    /// Wraps POSIX `read(2)` via `Kernel.IO.Read.read()`.
    ///
    /// - Parameter buffer: Buffer to read bytes into.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    public func callAsFunction(
        into buffer: UnsafeMutableRawBufferPointer
    ) throws(Kernel.IO.Read.Error) -> Int {
        let descriptor = Kernel.Descriptor(_rawValue: stream.rawValue)
        return try Kernel.IO.Read.read(descriptor, into: buffer)
    }
}

#endif
