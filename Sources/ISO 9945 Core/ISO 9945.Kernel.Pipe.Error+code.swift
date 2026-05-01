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

extension ISO_9945.Kernel.Pipe.Error {
    /// Creates an error from a POSIX error code.
    @inlinable
    public init(code: Error_Primitives.Error.Code) {
        if let e = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
            self = .handle(e)
            return
        }
        self = .platform(Error_Primitives.Error(code: code))
    }

    /// The underlying POSIX error code.
    ///
    /// Wave 3.5-1 (2026-05-01) — added to match the canonical pattern across
    /// other ISO_9945.Kernel.X.Error types (IO.Read.Error / IO.Write.Error /
    /// Close.Error / Lock.Error / File.Flush.Error / Socket.Error / etc.).
    /// Used by L3-policy wrappers checking EINTR via `error.code.isInterrupted`.
    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .handle(let e): return e.code
        case .platform(let e): return e.code
        }
    }
}
