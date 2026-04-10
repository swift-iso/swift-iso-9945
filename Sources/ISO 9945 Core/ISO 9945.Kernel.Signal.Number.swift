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

extension ISO_9945.Kernel.Signal {
    /// A signal number.
    ///
    /// Use named constants (`.interrupt`, `.terminate`, etc.) for portable code.
    /// Use `init(rawValue:)` as an escape hatch for platform-specific signals.
    public struct Number: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        /// Creates a signal number from a raw value.
        ///
        /// Prefer named constants when available. Use this initializer
        /// as an escape hatch for platform-specific signals.

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}
