// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.File.Stats.Kind {
    /// Device types.
    public enum Device: Sendable, Equatable, Hashable {
        /// Block device.
        case block

        /// Character device.
        case character
    }
}
