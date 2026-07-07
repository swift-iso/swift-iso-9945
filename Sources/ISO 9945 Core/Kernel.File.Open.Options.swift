// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel-primitives open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.File.Open {
    /// Options that modify file opening behavior.
    ///
    /// The raw value is the platform open flag directly (O_CREAT, O_TRUNC, etc.).
    /// Multiple options can be combined using bitwise OR.
    ///
    /// ## Platform Constants
    ///
    /// POSIX constants are in `swift-iso-9945` (`ISO_9945.Kernel.File.Open.Options`).
    /// Linux-specific constants are in `swift-linux-primitives`.
    /// Darwin-specific constants are in `swift-darwin-primitives`.
    public struct Options: OptionSet, Sendable, Hashable {
        /// The platform open flags.
        public let rawValue: Int32

        /// Creates options from raw platform flags.
        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}
