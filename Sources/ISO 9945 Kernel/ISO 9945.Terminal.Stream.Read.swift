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

public import Kernel_Primitives
public import Terminal_Primitives

extension Terminal.Stream.Read {
    /// Read bytes from this terminal stream.
    ///
    /// Delegates to `Kernel.IO.Read.read(_:Terminal.Stream, into:)` which
    /// performs the raw fd extraction at the C boundary. No `Kernel.Descriptor`
    /// is constructed — standard streams are process-owned and wrapping them
    /// in an owning `~Copyable` Descriptor would close them on deinit.
    ///
    /// - Parameter buffer: Buffer to read bytes into.
    /// - Returns: Number of bytes read. Returns 0 on EOF.
    /// - Throws: `Kernel.IO.Read.Error` on failure.
    public func callAsFunction(
        into buffer: UnsafeMutableRawBufferPointer
    ) throws(Kernel.IO.Read.Error) -> Int {
        try unsafe Kernel.IO.Read.read(stream, into: buffer)
    }
}

#endif
