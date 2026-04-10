// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

@_spi(Syscall) public import Kernel_Primitives_Core
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
@_spi(Syscall) public import Kernel_Socket_Primitives
@_spi(Syscall) public import Kernel_Memory_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_Permission_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_Thread_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Clock_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Syscall_Primitives
@_spi(Syscall) public import Kernel_Terminal_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Namespace

extension Kernel.Memory.Map {
    /// Flags for msync operation.
    public enum Sync: Sendable, Equatable, Hashable {}
}

// MARK: - Options Shell

extension Kernel.Memory.Map.Sync {
    /// Options for msync operation.
    public struct Options: Sendable, Equatable, Hashable {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Combines multiple flags.
        @inlinable
        public static func | (lhs: Kernel.Memory.Map.Sync.Options, rhs: Kernel.Memory.Map.Sync.Options) -> Kernel.Memory.Map.Sync.Options {
            Kernel.Memory.Map.Sync.Options(rawValue: lhs.rawValue | rhs.rawValue)
        }
    }
}

// MARK: - POSIX msync flags

extension Kernel.Memory.Map.Sync.Options {
    /// Synchronous sync - wait for I/O to complete.
    public static let sync = Self(rawValue: MS_SYNC)

    /// Asynchronous sync - schedule I/O but don't wait.
    public static let async = Self(rawValue: MS_ASYNC)

    /// Invalidate cached copies.
    public static let invalidate = Self(rawValue: MS_INVALIDATE)
}
