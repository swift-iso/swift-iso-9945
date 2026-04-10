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
import String_Primitives
public import ISO_9945_Core  // For ISO_9945.Loader typealias

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX Implementation

#if !os(Windows)

extension ISO_9945.Loader.Symbol {
    /// Looks up a symbol in a library or scope (POSIX).
    ///
    /// Wraps `dlsym` on POSIX systems.
    ///
    /// - Parameters:
    ///   - name: The symbol name (C string).
    ///   - scope: Where to search — a loaded `Handle` or special scope.
    /// - Returns: Pointer to the symbol.
    /// - Throws: `Loader.Error.symbol` if not found.
    ///
    /// ## Pointer Lifetime
    ///
    /// - Returned `UnsafeRawPointer` is valid only while the owning library remains loaded
    /// - Caller is responsible for correct casting and calling convention
    ///
    /// ## Example
    ///
    /// ```swift
    /// let sym = try Loader.Symbol.lookup(name: "myFunction", in: .default)
    /// typealias MyFunc = @convention(c) () -> Int32
    /// let func = unsafeBitCast(sym, to: MyFunc.self)
    /// ```
    @unsafe
    public static func lookup(
        name: UnsafePointer<CChar>,
        in scope: Scope
    ) throws(Loader.Error) -> UnsafeRawPointer {
        // Clear stale error
        _ = unsafe dlerror()

        let sym = unsafe dlsym(scope.dlsymHandle, name)

        // Check for error (sym can legitimately be NULL for data symbols)
        if let errorCStr = unsafe dlerror() {
            let u8Ptr = unsafe UnsafePointer<UInt8>(errorCStr)
            let view = unsafe String_Primitives.String.View(u8Ptr, count: String_Primitives.String.length(of: u8Ptr))
            throw .symbol(unsafe Loader.Message(copying: view))
        }

        guard let sym = unsafe sym else {
            throw .symbol(Loader.Message(ascii: "symbol resolved to NULL (no dlerror)"))
        }

        return UnsafeRawPointer(sym)
    }
}

#endif
