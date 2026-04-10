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

@_spi(Syscall) import Kernel_Primitives_Core
@_spi(Syscall) import Kernel_Descriptor_Primitives

extension ISO_9945 {
    /// ISO 9945 (POSIX) kernel mechanisms.
    ///
    /// This is a typealias to `Kernel_Primitives_Core.Kernel`, allowing POSIX-specific
    /// extensions to be added to the shared Kernel type.
    ///
    /// Low-level POSIX syscall wrappers for:
    /// - Signal handling (sigaction, sigprocmask, kill)
    /// - Process control (fork, exec, wait, exit)
    /// - Memory locking (mlockall)
    /// - Dynamic library loading (dlopen, dlsym, dlclose)
    public typealias Kernel = Kernel_Primitives_Core.Kernel
}
