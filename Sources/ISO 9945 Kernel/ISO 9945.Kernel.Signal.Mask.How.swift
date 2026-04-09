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
    import Darwin
#elseif canImport(Glibc)
    import Glibc
#elseif canImport(Musl)
    import Musl
#endif

extension ISO_9945.Kernel.Signal {
    /// Signal mask operations namespace.
    ///
    /// ## Threading
    ///
    /// Signal masks are per-thread. `Mask.change` uses `pthread_sigmask`
    /// which is thread-safe and affects only the calling thread.
    ///
    /// ## Blocking Behavior
    ///
    /// Operations are synchronous and non-blocking.
    public enum Mask {}
}

extension ISO_9945.Kernel.Signal.Mask {
    /// Specifies how to modify the signal mask.
    ///
    /// Used with `Mask.change(_:signals:)` to specify whether signals
    /// should be blocked, unblocked, or the mask replaced entirely.
    public struct How: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Block the specified signals (add to current mask).
        ///
        /// - POSIX: `SIG_BLOCK`
        public static let block = Self(rawValue: SIG_BLOCK)

        /// Unblock the specified signals (remove from current mask).
        ///
        /// - POSIX: `SIG_UNBLOCK`
        public static let unblock = Self(rawValue: SIG_UNBLOCK)

        /// Replace the current mask with the specified signals.
        ///
        /// - POSIX: `SIG_SETMASK`
        public static let set = Self(rawValue: SIG_SETMASK)
    }
}

// MARK: - CustomStringConvertible

extension ISO_9945.Kernel.Signal.Mask.How: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .block: return "block"
        case .unblock: return "unblock"
        case .set: return "set"
        default: return "how(\(rawValue))"
        }
    }
}
