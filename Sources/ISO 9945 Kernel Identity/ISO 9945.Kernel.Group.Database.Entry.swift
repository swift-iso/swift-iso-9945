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

extension ISO_9945.Kernel.Group.Database {
    /// A group database entry (from /etc/group or equivalent).
    public struct Entry: Sendable {
        /// The group name.
        public let name: String

        /// The group ID.
        public let gid: ISO_9945.Kernel.Group.ID

        /// The group member names.
        public let members: [String]
    }
}
