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

extension Kernel.IO.Write.Error {
    /// The underlying POSIX error code.
    @inlinable
    public var code: Error_Primitives.Error.Code {
        switch self {
        case .handle(let e): return e.code
        case .blocking(let e): return e.code
        case .io(let e): return e.code
        case .space(let e): return e.code
        case .memory(let e): return e.code
        case .platform(let e): return e.code
        }
    }
}

// MARK: - POSIX Error Code Mapping

extension Kernel.IO.Write.Error {
    /// Creates an error from a POSIX error code.
    @usableFromInline
    internal init(code: Error_Primitives.Error.Code) {
        if let e = Kernel.Descriptor.Validity.Error(code: code) {
            self = .handle(e)
            return
        }
        if let e = Kernel.IO.Blocking.Error(code: code) {
            self = .blocking(e)
            return
        }
        if let e = Kernel.IO.Error(code: code) {
            self = .io(e)
            return
        }
        if let e = Kernel.Storage.Error(code: code) {
            self = .space(e)
            return
        }
        if let e = Kernel.Memory.Error(code: code) {
            self = .memory(e)
            return
        }
        self = .platform(Error_Primitives.Error(code: code))
    }
}
