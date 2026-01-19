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

@_spi(Syscall) public import Kernel_Primitives
public import ISO_9945
public import String_Primitives
internal import ISO_9945_ABI

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Borrow-First APIs

extension ISO_9945.Kernel.Environment {

    /// Canonical primitive: scoped access to environment variable bytes.
    ///
    /// This is the most primitive API. It provides zero-copy access to the
    /// raw bytes of an environment variable. The closure receives a `Span`
    /// that does NOT include the NUL terminator.
    ///
    /// - Warning: The caller MUST NOT call `set`, `unset`, or any other
    ///   environment-modifying function during the closure. The underlying
    ///   storage is process-global and can be invalidated by such calls.
    ///
    /// - Parameters:
    ///   - name: Pointer to null-terminated variable name.
    ///   - body: A closure that processes the value bytes. Non-throwing.
    /// - Returns: The result of the closure, or `nil` if the variable is not set.
    public static func withValueBytes<R: ~Copyable>(
        _ name: UnsafePointer<Kernel.String.Char>,
        _ body: (Span<Kernel.String.Char>) -> R
    ) -> R? {
        let cName = unsafe UnsafePointer<CChar>(name)
        guard let valuePtr = unsafe getenv(cName) else {
            return nil
        }

        // Find length (getenv returns NUL-terminated string)
        var length = 0
        while (unsafe valuePtr[length]) != 0 {
            length += 1
        }

        let u8Ptr = unsafe UnsafePointer<UInt8>(valuePtr)
        let span = unsafe Span(_unsafeStart: u8Ptr, count: length)
        return body(span)
    }

    /// Convenience: scoped access as NUL-terminated view.
    ///
    /// This API provides a `Kernel.String.View` for APIs that expect
    /// NUL-terminated strings.
    ///
    /// - Warning: The caller MUST NOT call `set`, `unset`, or any other
    ///   environment-modifying function during the closure. The underlying
    ///   storage is process-global and can be invalidated by such calls.
    ///
    /// - Parameters:
    ///   - name: Pointer to null-terminated variable name.
    ///   - body: A closure that processes the value view. Non-throwing.
    /// - Returns: The result of the closure, or `nil` if the variable is not set.
    public static func withValue<R: ~Copyable>(
        _ name: UnsafePointer<Kernel.String.Char>,
        _ body: (borrowing Kernel.String.View) -> R
    ) -> R? {
        let cName = unsafe UnsafePointer<CChar>(name)
        guard let valuePtr = unsafe getenv(cName) else {
            return nil
        }

        let u8Ptr = unsafe UnsafePointer<UInt8>(valuePtr)
        let view = unsafe Kernel.String.View(u8Ptr)
        return body(view)
    }

    /// Owned convenience: gets an environment variable.
    ///
    /// This is the simplest API but involves allocation. For callers that
    /// need to transform the result (e.g., parse the value), prefer
    /// `withValueBytes` or `withValue` to avoid intermediate allocations.
    ///
    /// - Parameter name: Pointer to null-terminated variable name.
    /// - Returns: Owned copy of the value, or nil if not set.
    ///
    /// - Note: Returns an owned copy to avoid lifetime issues with
    ///   the internal storage which can be invalidated by setenv/unsetenv.
    public static func get(_ name: UnsafePointer<Kernel.String.Char>) -> Kernel.String? {
        withValue(name) { view in
            Kernel.String(copying: view)
        }
    }

    /// Sets an environment variable.
    ///
    /// - Parameters:
    ///   - name: Pointer to null-terminated variable name.
    ///   - value: Pointer to null-terminated value.
    ///   - overwrite: If true, overwrite existing value.
    /// - Throws: `Kernel.Environment.Error` on failure.

    public static func set(
        _ name: UnsafePointer<Kernel.String.Char>,
        to value: UnsafePointer<Kernel.String.Char>,
        overwrite: Bool = true
    ) throws(Kernel.Environment.Error) {
        let cName = unsafe UnsafePointer<CChar>(name)
        let cValue = unsafe UnsafePointer<CChar>(value)
        let result = unsafe setenv(cName, cValue, overwrite ? 1 : 0)
        guard result == 0 else {
            throw .current()
        }
    }

    /// Unsets an environment variable.
    ///
    /// - Parameter name: Pointer to null-terminated variable name.
    /// - Throws: `Kernel.Environment.Error` on failure.
    ///
    /// - Note: Does not fail if the variable does not exist.

    public static func unset(_ name: UnsafePointer<Kernel.String.Char>) throws(Kernel.Environment.Error) {
        let cName = unsafe UnsafePointer<CChar>(name)
        let result = unsafe unsetenv(cName)
        guard result == 0 else {
            throw .current()
        }
    }
}
