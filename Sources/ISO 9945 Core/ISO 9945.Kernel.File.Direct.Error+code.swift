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

// MARK: - POSIX Translation from Syscall

extension Kernel.File.Direct.Error {
    /// Creates a semantic error from a raw syscall error.
    public init(from syscall: Syscall) {
        switch syscall {
        case .invalidDescriptor:
            self = .invalidHandle

        case .alignmentViolation(let operation):
            self = .platform(code: .posix(-1), operation: operation)

        case .notSupported:
            self = .notSupported

        case .platform(let code, let operation):
            self.init(code: code, operation: operation)
        }
    }

    /// Maps a POSIX error code to a semantic error.
    @usableFromInline
    internal init(code: Kernel.Error.Code, operation: Operation) {
        switch code {
        case _ where code == .POSIX.EINVAL:
            self = .platform(code: code, operation: operation)
        case _ where code == .POSIX.EBADF:
            self = .invalidHandle
        case _ where Kernel.Error.Code.POSIX.isENOTSUP(code):
            self = .notSupported
        default:
            self = .platform(code: code, operation: operation)
        }
    }
}
