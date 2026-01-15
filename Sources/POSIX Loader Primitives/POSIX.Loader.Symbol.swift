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
    internal import Kernel_Primitives
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Loader {
    /// POSIX symbol lookup interface.
    ///
    /// Wraps `dlsym` on POSIX systems.
    public enum Symbol: Sendable {}
}

// MARK: - Scope Alias

extension ISO_9945.Loader.Symbol {
    /// Symbol lookup scope.
    ///
    /// Aliases to `Loader.Symbol.Scope` from swift-loader-primitives.
    public typealias Scope = Loader.Symbol.Scope
}

// MARK: - POSIX Implementation

#if !os(Windows)

extension ISO_9945.Loader.Symbol {
    /// Looks up a symbol in a library or scope.
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
    /// let sym = try POSIX.Loader.Symbol.lookup(name: "myFunction", in: .default)
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
            throw .symbol(Loader.Message(unsafe String(cString: errorCStr)))
        }

        guard let sym = unsafe sym else {
            throw .symbol(Loader.Message("symbol resolved to NULL (no dlerror)"))
        }

        return UnsafeRawPointer(sym)
    }
}

#endif
