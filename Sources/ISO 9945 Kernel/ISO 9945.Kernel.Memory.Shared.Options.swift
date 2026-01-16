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

// MARK: - POSIX Shared Memory Options Conversion

extension Kernel.Memory.Shared.Options {
    /// Converts the options to POSIX open flags.
    @usableFromInline
    internal var posixFlags: Int32 {
        var flags: Int32 = 0
        if contains(.create) { flags |= O_CREAT }
        if contains(.exclusive) { flags |= O_EXCL }
        if contains(.truncate) { flags |= O_TRUNC }
        return flags
    }
}
