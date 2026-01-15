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
public import POSIX_Primitives

extension ISO_9945 {
    /// ISO 9945 (POSIX) kernel mechanisms.
    ///
    /// This is a typealias to `Kernel_Primitives.Kernel`, allowing POSIX-specific
    /// extensions to be added to the shared Kernel type.
    ///
    /// Low-level POSIX syscall wrappers for:
    /// - Signal handling (sigaction, sigprocmask, kill)
    /// - Process control (fork, exec, wait, exit)
    /// - Memory locking (mlockall)
    /// - Dynamic library loading (dlopen, dlsym, dlclose)
    public typealias Kernel = Kernel_Primitives.Kernel
}

// MARK: - POSIX.Kernel.Descriptor Veneer

extension Kernel_Primitives.Kernel.Descriptor {
    /// Creates a descriptor by borrowing a POSIX file descriptor.
    ///
    /// - Parameter fd: The raw POSIX file descriptor (Int32).
    /// - Returns: A `Kernel.Descriptor` wrapping the file descriptor.
    public static func borrowing(_ fd: Int32) -> Self {
        Self(_rawValue: fd)
    }

    /// The raw POSIX file descriptor value.
    public var fileDescriptor: Int32 { _rawValue }
}
