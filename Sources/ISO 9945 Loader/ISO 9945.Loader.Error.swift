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

#if canImport(Darwin) || canImport(Glibc) || canImport(Musl)

public import Loader_Primitives
public import String_Primitives
public import ISO_9945  // For ISO_9945.Loader typealias
internal import ISO_9945_ABI

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Loader.Error {
    /// Captures dlerror() into a Loader.Message.
    ///
    /// MUST be called immediately after a failing loader call.
    /// Always returns a valid message (worst case: "unknown error").
    @usableFromInline
    internal static func captureError() -> Loader.Message {
        if let cstr = unsafe dlerror() {
            let u8Ptr = unsafe UnsafePointer<UInt8>(cstr)
            let view = unsafe String_Primitives.String.View(u8Ptr)
            return unsafe Loader.Message(copying: view)
        }
        // Fallback: create message from literal
        return Loader.Message(ascii: "unknown error")
    }
}
#endif
