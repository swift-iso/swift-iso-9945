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

// MARK: - Expand Namespace

extension ISO_9945.Glob {
    /// Namespace for `glob(3)` types.
    public enum Expand: Sendable {}
}

// MARK: - glob(3) Wrapper

extension ISO_9945.Glob {
    /// Wraps `glob(3)`. Expands a pattern into matching paths.
    ///
    /// Allocates internally via `glob_t`. Prefer `Kernel.Glob.match` at L3
    /// for streaming results and `**` support.
    ///
    /// - Parameters:
    ///   - pattern: Glob pattern to expand.
    ///   - options: `GLOB_*` flags controlling expansion behavior.
    /// - Returns: Array of matching paths as strings.
    /// - Throws: `Expand.Error` on failure.
    public static func expand(
        pattern: borrowing Kernel.Path.View,
        options: Expand.Options = []
    ) throws(Expand.Error) -> [Swift.String] {
        var gt = unsafe glob_t()

        let result = unsafe iso9945_glob(
            UnsafeRawPointer(pattern.pointer).assumingMemoryBound(to: CChar.self),
            options.rawValue,
            nil,
            &gt
        )
        defer { unsafe iso9945_globfree(&gt) }

        switch result {
        case 0:
            var paths: [Swift.String] = []
            let count = unsafe Int(gt.gl_pathc)
            paths.reserveCapacity(count)

            for i in 0..<count {
                if let cPath = unsafe gt.gl_pathv[i] {
                    paths.append(unsafe Swift.String(cString: cPath))
                }
            }
            return paths

        case iso9945_glob_nomatch():
            throw .noMatch

        case iso9945_glob_nospace():
            throw .noSpace

        case iso9945_glob_aborted():
            throw .aborted

        default:
            throw .aborted
        }
    }
}
