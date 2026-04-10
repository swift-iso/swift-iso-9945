// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-posix open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-posix project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Kernel_Primitives_Core
public import Kernel_Descriptor_Primitives
public import Kernel_Error_Primitives
public import Kernel_File_Primitives
public import Kernel_IO_Primitives
public import Kernel_Socket_Primitives
public import Kernel_Memory_Primitives
public import Kernel_Process_Primitives
public import Kernel_Permission_Primitives
public import Kernel_Path_Primitives
public import Kernel_Thread_Primitives
public import Kernel_System_Primitives
public import Kernel_Time_Primitives
public import Kernel_Clock_Primitives
public import Kernel_Random_Primitives
public import Kernel_Environment_Primitives
public import Kernel_Syscall_Primitives
public import Kernel_Terminal_Primitives
public import ISO_9945

extension ISO_9945.Kernel {
    /// POSIX signal handling.
    ///
    /// Signal handling operations including:
    /// - Signal sets (sigset_t operations)
    /// - Signal masks (pthread_sigmask)
    /// - Signal actions (sigaction)
    /// - Signal sending (kill, raise)
    ///
    /// ## Threading
    ///
    /// All signal operations are thread-safe (kernel provides synchronization).
    /// Signal masks are per-thread; use `pthread_sigmask` (wrapped by `Signal.Mask`)
    /// rather than `sigprocmask` for multithreaded programs.
    ///
    /// ## Blocking Behavior
    ///
    /// Operations are synchronous and non-blocking (immediate kernel calls).
    /// No operation in this namespace waits for signals to arrive.
    ///
    /// ## Cancellation
    ///
    /// POSIX signal syscalls are not cancellable. EINTR is returned as
    /// `Signal.Error.interrupted` for caller-determined retry policy.
    ///
    /// ## Design
    ///
    /// POSIX.Kernel does NOT automatically retry on EINTR. Higher layers
    /// decide retry policy based on their semantics.
    public enum Signal: Sendable {}
}
