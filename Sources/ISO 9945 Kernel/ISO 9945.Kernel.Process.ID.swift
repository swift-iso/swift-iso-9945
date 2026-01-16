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

// MARK: - POSIX process ID operations

extension ISO_9945.Kernel.Process {
    public typealias ID = Kernel.Process.ID
}

extension Kernel.Process.ID {
    /// The current process.

    public static var current: Self {
        #if canImport(Darwin)
            Self(Darwin.getpid())
        #elseif canImport(Musl)
            Self(Musl.getpid())
        #elseif canImport(Glibc)
            Self(Glibc.getpid())
        #endif
    }

    /// The parent process.

    public static var parent: Self {
        #if canImport(Darwin)
            Self(Darwin.getppid())
        #elseif canImport(Musl)
            Self(Musl.getppid())
        #elseif canImport(Glibc)
            Self(Glibc.getppid())
        #endif
    }
}
