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

// MARK: - Platform-Neutral Semantic Predicates
//
// These accessors let consumers describe a failure condition in domain terms
// (`isNotFound`, `isPermissionDenied`, …) instead of hand-switching between
// `Kernel.Error.Code.POSIX.*` and `Kernel.Error.Code.Windows.*`. The Windows
// bodies live in `Windows.Kernel.Error.Code+Predicates.swift` in
// swift-windows-standard; each package contributes the branch that is correct
// for its platform. Consumers see a single unified API via the re-export chain
// exposed by `import Kernel`.
//
// ```swift
// if error.code.isNotFound {
//     // Handle the "not found" failure uniformly across platforms.
// }
// ```

extension Kernel.Error.Code {
    /// Returns `true` if this error code indicates that a requested file or directory does not exist.
    ///
    /// Maps to `ENOENT` on POSIX platforms.
    @inlinable
    public var isNotFound: Bool {
        self == .POSIX.ENOENT
    }

    /// Returns `true` if this error code indicates that the caller does not have permission for the operation.
    ///
    /// Maps to `EACCES` (file-system access control) and `EPERM` (privileged operation) on POSIX platforms.
    @inlinable
    public var isPermissionDenied: Bool {
        self == .POSIX.EACCES || self == .POSIX.EPERM
    }

    /// Returns `true` if this error code indicates access was denied.
    ///
    /// Semantic alias of ``isPermissionDenied`` preserved so existing consumer code
    /// using either name continues to type-check. New call sites should prefer
    /// ``isPermissionDenied``.
    @inlinable
    public var isAccessDenied: Bool {
        isPermissionDenied
    }

    /// Returns `true` if this error code indicates a write to a read-only file system.
    ///
    /// Maps to `EROFS` on POSIX platforms.
    @inlinable
    public var isReadOnly: Bool {
        self == .POSIX.EROFS
    }

    /// Returns `true` if this error code indicates the storage device is out of space.
    ///
    /// Maps to `ENOSPC` on POSIX platforms.
    @inlinable
    public var isNoSpace: Bool {
        self == .POSIX.ENOSPC
    }

    /// Returns `true` if this error code indicates a path component was expected to be a directory but was not.
    ///
    /// Maps to `ENOTDIR` on POSIX platforms.
    @inlinable
    public var isNotDirectory: Bool {
        self == .POSIX.ENOTDIR
    }

    /// Returns `true` if this error code indicates a syntactically invalid path.
    ///
    /// POSIX has no distinct errno for malformed path syntax — such failures surface
    /// as `ENOENT` or `ENOTDIR` during resolution. This predicate is defined here so
    /// the method remains visible to platform-neutral consumers; it always returns
    /// `false` on POSIX.
    @inlinable
    public var isInvalidPath: Bool {
        false
    }

    /// Returns `true` if this error code indicates a network path or name could not be resolved.
    ///
    /// POSIX has no distinct errno for network-path resolution — such failures surface
    /// through socket-level or name-resolution errors. This predicate is defined here
    /// so the method remains visible to platform-neutral consumers; it always returns
    /// `false` on POSIX.
    @inlinable
    public var isNetworkNotFound: Bool {
        false
    }
}
