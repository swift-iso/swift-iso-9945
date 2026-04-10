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

extension ISO_9945.Kernel.Signal.Action {
    /// Swift representation of signal action configuration.
    ///
    /// Encapsulates handler, mask, and flags without exposing the
    /// platform-specific `sigaction` struct layout.
    ///
    /// ## Invariants
    ///
    /// - If `handler` is `.customInfo`, `flags` will contain `.sigInfo`.
    /// - If `handler` is `.custom`, `flags` will NOT contain `.sigInfo`.
    ///
    /// These invariants are enforced by the initializer.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Simple handler with restart flag
    /// let config = Configuration(
    ///     handler: .custom(myHandler),
    ///     flags: .restart
    /// )
    ///
    /// // Handler with extended info (sigInfo flag added automatically)
    /// let config = Configuration(
    ///     handler: .customInfo(myInfoHandler),
    ///     flags: .restart
    /// )
    ///
    /// // Block other signals while handler runs
    /// var blocked = POSIX.Kernel.Signal.Set()
    /// try blocked.insert(.terminate)
    /// let config = Configuration(
    ///     handler: .custom(myHandler),
    ///     mask: blocked
    /// )
    /// ```
    @safe
    public struct Configuration: Sendable {
        /// The handler disposition for the signal.
        public let handler: Handler

        /// Signals to block while the handler executes.
        ///
        /// The caught signal is always blocked during handler execution
        /// unless `.noDefer` flag is set.
        public let mask: POSIX.Kernel.Signal.Set

        /// Options modifying signal handling behavior.
        public let flags: Options

        /// Creates a signal action configuration.
        ///
        /// - Parameters:
        ///   - handler: The handler disposition for the signal.
        ///   - mask: Signals to block while handler executes. Defaults to empty.
        ///   - flags: Options modifying signal behavior. Defaults to none.
        ///
        /// ## Invariant Enforcement
        ///
        /// - If `handler` is `.customInfo`, `.sigInfo` flag is added automatically.
        /// - If `handler` is `.custom`, `.sigInfo` flag is removed if present.

        @unsafe
        public init(
            handler: Handler,
            mask: POSIX.Kernel.Signal.Set = POSIX.Kernel.Signal.Set(),
            flags: Options = []
        ) {
            unsafe (self.handler = handler)
            self.mask = mask

            // Enforce invariants
            switch unsafe handler {
            case .customInfo:
                // SA_SIGINFO required for sa_sigaction handler
                self.flags = flags.union(.sigInfo)
            case .custom:
                // SA_SIGINFO must NOT be set for sa_handler
                self.flags = flags.subtracting(.sigInfo)
            case .default, .ignore:
                self.flags = flags
            }
        }

        /// Creates a configuration without invariant enforcement.
        ///
        /// Used internally when reconstructing from kernel state where
        /// the handler/flags relationship is already correct.
        @unsafe
        internal init(
            __unchecked: Void,
            handler: Handler,
            mask: POSIX.Kernel.Signal.Set,
            flags: Options
        ) {
            unsafe (self.handler = handler)
            self.mask = mask
            self.flags = flags
        }
    }
}
