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

extension Kernel.File.Open.Error {
    /// Creates an error by mapping a POSIX error code to the appropriate case.
    ///
    /// Available via `@_spi(Syscall)` for platform-specific packages.
    @_spi(Syscall)
    @inlinable
    public init(code: Kernel.Error.Code) {
        if let e = Kernel.Path.Resolution.Error(code: code) {
            self = .path(e)
            return
        }
        if let e = Kernel.Permission.Error(code: code) {
            self = .permission(e)
            return
        }
        if let e = Kernel.Descriptor.Validity.Error(code: code) {
            self = .handle(e)
            return
        }
        if let e = Kernel.Storage.Error(code: code) {
            self = .space(e)
            return
        }
        if let e = Kernel.IO.Error(code: code) {
            self = .io(e)
            return
        }
        self = .platform(Kernel.Error(code: code))
    }
}
