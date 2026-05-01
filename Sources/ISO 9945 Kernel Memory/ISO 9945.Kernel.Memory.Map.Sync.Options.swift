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

extension Memory.Map.Sync {
    /// Options for msync operation.
    public struct Options: Sendable, Equatable, Hashable {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Combines multiple flags.
        @inlinable
        public static func | (lhs: Memory.Map.Sync.Options, rhs: Memory.Map.Sync.Options) -> Memory.Map.Sync.Options {
            Memory.Map.Sync.Options(rawValue: lhs.rawValue | rhs.rawValue)
        }
    }
}

// MARK: - POSIX msync flags

extension Memory.Map.Sync.Options {
    /// Synchronous sync - wait for I/O to complete.
    public static let sync = Self(rawValue: MS_SYNC)

    /// Asynchronous sync - schedule I/O but don't wait.
    public static let async = Self(rawValue: MS_ASYNC)

    /// Invalidate cached copies.
    public static let invalidate = Self(rawValue: MS_INVALIDATE)
}
