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

import Memory_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Memory.Lock.All {
    /// Options for mlockall/munlockall.
    ///
    /// ## Platform Constants
    ///
    /// Linux-specific constants (MCL_ONFAULT) are in `swift-linux-primitives`.
    public struct Options: Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension Memory.Lock.All.Options {
    /// Combines multiple flags.
    public static func | (lhs: Self, rhs: Self) -> Self {
        Self(rawValue: lhs.rawValue | rhs.rawValue)
    }

    /// Checks if this contains another flag.
    public func contains(_ other: Self) -> Bool {
        (rawValue & other.rawValue) == other.rawValue
    }
}

// MARK: - POSIX Standard mlockall Options

extension Memory.Lock.All.Options {
    /// Lock all pages currently mapped into the address space.
    public static let current = Self(rawValue: MCL_CURRENT)

    /// Lock all pages that become mapped in the future.
    public static let future = Self(rawValue: MCL_FUTURE)
}
