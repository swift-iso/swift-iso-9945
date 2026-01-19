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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Shared Memory Options

extension ISO_9945.Kernel.Memory.Shared {
    /// Creation options for shared memory objects.
    ///
    /// An OptionSet using POSIX flag values directly. Multiple options
    /// can be combined using array literal syntax.
    ///
    /// ## Usage
    /// ```swift
    /// // Create if doesn't exist
    /// let fd = try Kernel.Memory.Shared.open(name: "/myshm", access: .readWrite, options: .create, ...)
    ///
    /// // Create exclusively (fail if exists)
    /// let fd = try Kernel.Memory.Shared.open(name: "/myshm", access: .readWrite, options: [.create, .exclusive], ...)
    /// ```
    public struct Options: OptionSet, Sendable, Hashable {
        /// The POSIX open flags.
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Standard Options

extension ISO_9945.Kernel.Memory.Shared.Options {
    /// Create the shared memory object if it doesn't exist (O_CREAT).
    public static let create = Self(rawValue: O_CREAT)

    /// Fail if the object already exists (O_EXCL). Requires `.create`.
    public static let exclusive = Self(rawValue: O_EXCL)

    /// Truncate the object to zero length if it exists (O_TRUNC). Requires `.create`.
    public static let truncate = Self(rawValue: O_TRUNC)
}
