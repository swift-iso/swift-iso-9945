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

@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_Memory_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.Memory.Lock.All {
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

        /// Combines multiple flags.
        public static func | (lhs: Options, rhs: Options) -> Options {
            Options(rawValue: lhs.rawValue | rhs.rawValue)
        }

        /// Checks if this contains another flag.
        public func contains(_ other: Options) -> Bool {
            (rawValue & other.rawValue) == other.rawValue
        }
    }
}

// MARK: - POSIX Standard mlockall Options

extension Kernel.Memory.Lock.All.Options {
    /// Lock all pages currently mapped into the address space.
    public static let current = Self(rawValue: MCL_CURRENT)

    /// Lock all pages that become mapped in the future.
    public static let future = Self(rawValue: MCL_FUTURE)
}
