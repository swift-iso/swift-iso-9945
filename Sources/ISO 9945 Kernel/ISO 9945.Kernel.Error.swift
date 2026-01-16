// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-posix open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-posix project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Kernel_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Error {
    /// Captures current errno as a `Kernel.Error.Code`.
    ///
    /// Must be called immediately after a failing syscall, before any other libc call.
    public static func captureErrno() -> Kernel.Error.Code {
        .posix(errno)
    }
}

extension Kernel.Error {
    /// Captures current errno and creates a Kernel.Error with operation context.
    ///
    /// Must be called immediately after a failing syscall, before any other libc call.
    ///
    /// - Parameter operation: Description of the failing operation.
    /// - Returns: A throwable Kernel.Error with errno captured.
    public static func current(
        operation: StaticString,
        function: StaticString = #function,
        fileID: StaticString = #fileID,
        line: UInt32 = #line
    ) -> Self {
        .capturing(.posix(errno), operation: operation, function: function, fileID: fileID, line: line)
    }
}
