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

extension Kernel.File.At {
    /// Path resolution flags (AT_* constants).
    ///
    /// Controls how *at() syscall variants resolve paths relative to
    /// directory file descriptors.
    public struct Options: OptionSet, Sendable {
        /// The platform path resolution flags.
        public let rawValue: Int32

        /// Creates options from raw platform flags.
        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - POSIX AT_* Constants

extension Kernel.File.At.Options {
    /// Do not follow symbolic links (AT_SYMLINK_NOFOLLOW).
    public static let noFollow = Self(rawValue: Int32(AT_SYMLINK_NOFOLLOW))

    /// Allow operations on empty path with fd (AT_EMPTY_PATH).
    public static let emptyPath = Self(rawValue: Int32(AT_EMPTY_PATH))

    /// Follow symbolic links (AT_SYMLINK_FOLLOW).
    public static let symlinkFollow = Self(rawValue: Int32(AT_SYMLINK_FOLLOW))

    /// Remove directory instead of file (AT_REMOVEDIR).
    public static let removeDirectory = Self(rawValue: Int32(AT_REMOVEDIR))
}
