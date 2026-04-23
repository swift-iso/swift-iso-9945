// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

internal import CISO9945Shim

// MARK: - Fnmatch Namespace

extension ISO_9945.Glob {
    /// Namespace for `fnmatch(3)` types.
    public enum Fnmatch: Sendable {}
}

// MARK: - fnmatch(3) Wrapper

extension ISO_9945.Glob {
    /// Wraps `fnmatch(3)`. Returns `true` if `name` matches `pattern`.
    ///
    /// Both parameters are `Kernel.Path.Borrowed` — null-terminated by invariant.
    /// The C `fnmatch()` reads but does not store the pointers. All unsafe
    /// is internal to this function body.
    ///
    /// - Parameters:
    ///   - pattern: Glob pattern (e.g., `*.swift`).
    ///   - name: Filename to match against the pattern.
    ///   - options: `FNM_*` flags controlling match behavior.
    /// - Returns: `true` if the name matches the pattern.
    public static func fnmatch(
        pattern: borrowing Kernel.Path.Borrowed,
        name: borrowing Kernel.Path.Borrowed,
        options: Fnmatch.Options = []
    ) -> Bool {
        let result = unsafe iso9945_fnmatch(
            UnsafeRawPointer(pattern.pointer).assumingMemoryBound(to: CChar.self),
            UnsafeRawPointer(name.pointer).assumingMemoryBound(to: CChar.self),
            options.rawValue
        )
        return result == 0
    }
}
