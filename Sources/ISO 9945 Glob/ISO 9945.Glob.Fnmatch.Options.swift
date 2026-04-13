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

extension ISO_9945.Glob.Fnmatch {
    /// Options for `fnmatch(3)` — wraps `FNM_*` flags.
    public struct Options: OptionSet, Sendable {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Glob.Fnmatch.Options {
    /// Slash in `name` is only matched by a slash in `pattern` (`FNM_PATHNAME`).
    public static let pathname = Self(rawValue: iso9945_fnm_pathname())

    /// Disable backslash escaping (`FNM_NOESCAPE`).
    public static let noescape = Self(rawValue: iso9945_fnm_noescape())

    /// Leading period in `name` must be matched by a literal period
    /// in `pattern` — not by `*`, `?`, or `[...]` (`FNM_PERIOD`).
    public static let period = Self(rawValue: iso9945_fnm_period())

    /// Case-insensitive matching (`FNM_CASEFOLD`).
    ///
    /// POSIX Issue 8 (2024). On implementations that do not yet support
    /// this flag, the rawValue is 0 — inserting it is a no-op and matching
    /// gracefully degrades to case-sensitive.
    public static let casefold = Self(rawValue: iso9945_fnm_casefold())
}
