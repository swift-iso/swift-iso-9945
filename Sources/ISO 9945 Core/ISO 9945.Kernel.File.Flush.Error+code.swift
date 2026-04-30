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

// MARK: - POSIX Error Code Access

extension ISO_9945.Kernel.File.Flush.Error {
    /// The underlying POSIX error code.
    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .handle(let e): return e.code
        case .platform(let e): return e.code
        }
    }
}
