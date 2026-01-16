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

// MARK: - POSIX file open mode conversion

extension Kernel.File.Open.Mode {
    /// Converts the mode to POSIX open flags.
    @usableFromInline
    internal var posixFlags: Int32 {
        let hasRead = contains(.read)
        let hasWrite = contains(.write)

        if hasRead && hasWrite {
            return O_RDWR
        } else if hasWrite {
            return O_WRONLY
        } else {
            return O_RDONLY
        }
    }
}
