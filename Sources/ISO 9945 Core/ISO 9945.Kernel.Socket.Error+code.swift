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

extension Kernel.Socket.Error {
    /// The underlying POSIX error code.
    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .handle(let e): return e.code
        case .platform(let e): return e.code
        }
    }
}

// MARK: - POSIX Error Code Mapping

extension Kernel.Socket.Error {
    /// Creates an error from a POSIX error code.
    @inlinable
    public init(code: Error_Primitives.Error.Code) {
        if let e = Kernel.Descriptor.Validity.Error(code: code) {
            self = .handle(e)
            return
        }
        self = .platform(Error_Primitives.Error(code: code))
    }
}
