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

extension ISO_9945.Kernel.User.Database {
    /// A user database entry (from /etc/passwd or equivalent).
    public struct Entry: Sendable {
        /// The user name.
        public let name: String

        /// The user ID.
        public let uid: ISO_9945.Kernel.User.ID

        /// The primary group ID.
        public let gid: ISO_9945.Kernel.Group.ID

        /// The user's home directory.
        public let home: String

        /// The user's login shell.
        public let shell: String
    }
}
