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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#elseif os(Windows)
    // CRT is the Swift overlay over ucrt: `errno` and the standard streams are
    // vended as computed accessors, and errno.h / string.h / stdlib.h symbols
    // (E* constants, strerror, getenv) import directly.
    internal import CRT
#endif

extension Error_Primitives.Error {
    /// Captures current errno as a `Error_Primitives.Error.Code`.
    ///
    /// Must be called immediately after a failing syscall, before any other libc call.
    public static func captureErrno() -> Error_Primitives.Error.Code {
        .posix(errno)
    }
}

extension Error_Primitives.Error {
    /// Captures current errno and creates a Error_Primitives.Error with operation context.
    ///
    /// Must be called immediately after a failing syscall, before any other libc call.
    ///
    /// - Parameter operation: Description of the failing operation.
    /// - Returns: A throwable Error_Primitives.Error with errno captured.
    public static func current(
        operation: StaticString,
        function: StaticString = #function,
        fileID: StaticString = #fileID,
        line: UInt32 = #line
    ) -> Self {
        .capturing(.posix(errno), operation: operation, function: function, file: .init(id: fileID), line: line)
    }
}
