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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Signal.Action {
    /// Signal action flags.
    ///
    /// These flags modify how signals are handled when delivered.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Restart interrupted syscalls automatically
    /// let config = POSIX.Kernel.Signal.Action.Configuration(
    ///     handler: .custom(myHandler),
    ///     flags: .restart
    /// )
    ///
    /// // Use extended signal info
    /// let config = POSIX.Kernel.Signal.Action.Configuration(
    ///     handler: .customInfo(myInfoHandler),
    ///     flags: [.restart, .sigInfo]  // sigInfo added automatically
    /// )
    /// ```
    public struct Flags: OptionSet, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Don't send `SIGCHLD` when children stop.
        ///
        /// - POSIX: `SA_NOCLDSTOP`
        public static let noChildStop = Self(rawValue: Int32(truncatingIfNeeded: SA_NOCLDSTOP))

        /// Don't create zombie on child death.
        ///
        /// - POSIX: `SA_NOCLDWAIT`
        public static let noChildWait = Self(rawValue: Int32(truncatingIfNeeded: SA_NOCLDWAIT))

        /// Reset handler to default after signal is caught.
        ///
        /// - POSIX: `SA_RESETHAND`
        public static let resetHandler = Self(rawValue: Int32(truncatingIfNeeded: SA_RESETHAND))

        /// Restart interrupted syscalls automatically.
        ///
        /// - POSIX: `SA_RESTART`
        public static let restart = Self(rawValue: Int32(truncatingIfNeeded: SA_RESTART))

        /// Use alternate signal stack (requires sigaltstack setup).
        ///
        /// - POSIX: `SA_ONSTACK`
        public static let onStack = Self(rawValue: Int32(truncatingIfNeeded: SA_ONSTACK))

        /// Don't block signal while handler executes.
        ///
        /// - POSIX: `SA_NODEFER`
        public static let noDefer = Self(rawValue: Int32(truncatingIfNeeded: SA_NODEFER))

        /// Use `sa_sigaction` handler instead of `sa_handler`.
        ///
        /// Required when using `.customInfo` handler. The `Configuration`
        /// initializer enforces this automatically.
        ///
        /// - POSIX: `SA_SIGINFO`
        public static let sigInfo = Self(rawValue: Int32(truncatingIfNeeded: SA_SIGINFO))
    }
}
