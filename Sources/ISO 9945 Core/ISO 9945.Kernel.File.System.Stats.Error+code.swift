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

extension Kernel.File.System.Stats.Error {
    /// Creates an error from a POSIX error code.
    @usableFromInline
    internal init(code: Kernel.Error.Code) {
        if let e = Kernel.Path.Resolution.Error(code: code) {
            self = .path(e)
            return
        }
        if let e = Kernel.Descriptor.Validity.Error(code: code) {
            self = .handle(e)
            return
        }
        if let e = Kernel.Permission.Error(code: code) {
            self = .permission(e)
            return
        }
        if let e = Kernel.Memory.Error(code: code) {
            self = .memory(e)
            return
        }
        if let e = Kernel.IO.Error(code: code) {
            self = .io(e)
            return
        }
        self = .platform(Kernel.Error(code: code))
    }
}
