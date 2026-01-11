// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-loader open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-loader project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Loader_Primitives
public import POSIX_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension POSIX.Loader {
    /// Errors from POSIX dynamic loader operations.
    ///
    /// Wraps `Loader.Error` with POSIX-specific error capture from `dlerror()`.
    public typealias Error = Loader.Error
}

// MARK: - Error Capture

#if !os(Windows)
extension POSIX.Loader {
    /// Captures dlerror() into a Loader.Message.
    ///
    /// MUST be called immediately after a failing loader call.
    /// Always returns a valid message (worst case: "unknown error").
    @usableFromInline
    internal static func captureError() -> Loader.Message {
        if let cstr = dlerror() {
            return Loader.Message(String(cString: cstr))
        }
        return Loader.Message("unknown error")
    }
}
#endif
