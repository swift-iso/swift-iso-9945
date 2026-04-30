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

// MARK: - POSIX Error Code Mapping

extension ISO_9945.Kernel.Socket.Shutdown.Error {
    /// Creates an error from a POSIX error code.
    @usableFromInline
    internal init(code: Error_Primitives.Error.Code) {
        self = .platform(Error_Primitives.Error(code: code))
    }
}
