// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.File.Clone.Error {
    /// Operation types for error context.
    public enum Operation: Swift.String, Sendable, Equatable {
        case clonefile
        case copyfile
        case ficlone
        case copyFileRange
        case duplicateExtents
        case statfs
        case stat
        case copy
    }
}
