// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


extension Kernel.Permission {
    /// Permission-related errors.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Permission denied - file/directory access control.
        /// - POSIX: `EACCES`
        /// - Windows: `ERROR_ACCESS_DENIED`
        case denied

        /// Operation not permitted - requires elevated privilege.
        /// - POSIX: `EPERM`
        ///
        /// Unlike `.denied`, this indicates the operation itself
        /// requires special privileges (e.g., changing file ownership
        /// to another user).
        case notPermitted

        /// Read-only filesystem.
        /// - POSIX: `EROFS`
        case readOnlyFilesystem
    }
}

// MARK: - CustomStringConvertible

extension Kernel.Permission.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .denied:
            return "permission denied"
        case .notPermitted:
            return "operation not permitted"
        case .readOnlyFilesystem:
            return "read-only filesystem"
        }
    }
}

// MARK: - Platform Bindings
//
// Per [PLAT-ARCH-008c], the platform-specific `init?(code:)` mapping lives in L2:
// - POSIX: `swift-iso-9945` (`ISO 9945.Kernel.Permission.Error+code.swift`)
// - Windows: `swift-windows-standard` (`Windows.Kernel.Permission.Error+code.swift`)

