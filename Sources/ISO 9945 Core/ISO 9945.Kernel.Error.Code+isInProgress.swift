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

extension Error_Primitives.Error.Code {
    /// Whether this code reports an asynchronous non-blocking connect in progress.
    @inlinable
    public var isInProgress: Bool {
        self == .posix(Error_Primitives.Error.Number.inProgress.underlying)
    }
}
