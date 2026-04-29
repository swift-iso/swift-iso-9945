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
    public init(code: Error_Primitives.Error.Code) {
        if let e = Path.Resolution.Error(code: code) {
            self = .path(e)
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
        self = .platform(Error_Primitives.Error(code: code))
    }
}
