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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX environment variable operations

extension ISO_9945.Kernel.Environment {
    /// Gets an environment variable.
    ///
    /// - Parameter name: Pointer to null-terminated variable name.
    /// - Returns: Owned copy of the value, or nil if not set.
    ///
    /// - Note: Returns an owned copy to avoid lifetime issues with
    ///   the internal storage which can be invalidated by setenv/unsetenv.

    public static func get(_ name: UnsafePointer<Kernel.String.Char>) -> Kernel.String? {
        guard let valuePtr = getenv(name) else {
            return nil
        }
        let view = Kernel.String.View(valuePtr)
        return Kernel.String(copying: view)
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
        let result = setenv(name, value, overwrite ? 1 : 0)
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
        let result = unsetenv(name)
        guard result == 0 else {
            throw .current()
        }
    }
}
