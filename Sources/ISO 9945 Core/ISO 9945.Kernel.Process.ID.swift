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

extension ISO_9945.Kernel.Process {
    /// POSIX process identifier (`pid_t` width: `Int32`).
    ///
    /// `Int32` matches the POSIX `pid_t` width 1:1 across all conformant
    /// systems without the consumer needing to import a platform C module.
    /// Negative values can be sentinels (e.g., `-1` from `wait(2)`); see
    /// platform syscall documentation for which sentinels apply.
    public struct ID: RawRepresentable, Sendable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Process.ID {
    /// The init process (pid 1).
    public static var `init`: Self { Self(1) }
}
