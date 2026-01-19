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

@_spi(Syscall) public import Kernel_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX environment error mapping

extension ISO_9945.Kernel.Environment.Error {
    public init(code: Kernel.Error.Code) {
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
        self = .platform(Kernel.Error(code: code))
    }

    public static func current() -> Self {
        Self(code: .captureErrno())
    }
}
