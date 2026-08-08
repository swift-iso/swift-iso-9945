// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.File.Access {
    /// Access requirements for a file.
    ///
    /// An empty requirement set performs the POSIX existence check. The
    /// stored representation is deliberately not public: callers compose
    /// typed requirements without depending on `R_OK`, `W_OK`, or `X_OK`.
    public struct Mode: Sendable, Equatable, Hashable {
        package let readable: Bool
        package let writable: Bool
        package let executable: Bool

        /// Creates an access mode from its semantic requirements.
        public init(
            read: Bool = false,
            write: Bool = false,
            execute: Bool = false
        ) {
            self.readable = read
            self.writable = write
            self.executable = execute
        }
    }
}

extension ISO_9945.Kernel.File.Access.Mode {
    /// Tests only whether the path exists.
    public static let existence = Self()

    /// Requires read access.
    public static let read = Self(read: true)

    /// Requires write access.
    public static let write = Self(write: true)

    /// Requires execute or directory-search access.
    public static let execute = Self(execute: true)
}
