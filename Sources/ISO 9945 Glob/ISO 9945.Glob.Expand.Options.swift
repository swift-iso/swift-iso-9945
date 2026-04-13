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

extension ISO_9945.Glob.Expand {
    /// Options for `glob(3)` — wraps `GLOB_*` flags.
    public struct Options: OptionSet, Sendable {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Glob.Expand.Options {
    /// Return on error (`GLOB_ERR`).
    public static let err = Self(rawValue: iso9945_glob_err())

    /// Append `/` to names that are directories (`GLOB_MARK`).
    public static let mark = Self(rawValue: iso9945_glob_mark())

    /// Do not sort the results (`GLOB_NOSORT`).
    public static let nosort = Self(rawValue: iso9945_glob_nosort())

    /// If no matches, return the pattern itself (`GLOB_NOCHECK`).
    public static let nocheck = Self(rawValue: iso9945_glob_nocheck())

    /// Disable backslash escaping (`GLOB_NOESCAPE`).
    public static let noescape = Self(rawValue: iso9945_glob_noescape())
}

extension ISO_9945.Glob.Expand {
    /// Errors from `glob(3)`.
    public enum Error: Swift.Error, Sendable {
        /// Memory allocation failure (`GLOB_NOSPACE`).
        case noSpace

        /// Read error or error function returned non-zero (`GLOB_ABORTED`).
        case aborted

        /// No matches found (`GLOB_NOMATCH`).
        case noMatch
    }
}
