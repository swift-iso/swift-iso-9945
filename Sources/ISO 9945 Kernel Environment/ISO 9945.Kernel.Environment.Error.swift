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

@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_Environment_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX environment error mapping

extension ISO_9945.Kernel.Environment.Error {
    internal init(code: Error_Primitives.Error.Code) {
        if let e = Kernel.Memory.Error(code: code) {
            self = .memory(e)
            return
        }
        if let e = Kernel.Permission.Error(code: code) {
            self = .permission(e)
            return
        }
        // EINVAL maps to invalid argument
        if case .posix(let errno) = code, errno == EINVAL {
            self = .invalid(.nameContainsEquals)
            return
        }
        self = .platform(Error_Primitives.Error(code: code))
    }

    internal static func current() -> Self {
        Self(code: .captureErrno())
    }
}
