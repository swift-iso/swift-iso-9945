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

extension ISO_9945.Kernel.Process.Wait {
    /// Options for wait operations.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Non-blocking wait
    /// let result = try POSIX.Kernel.Process.Wait.wait(.any, options: .no.hang)
    ///
    /// // Wait for stopped children
    /// let result = try POSIX.Kernel.Process.Wait.wait(.any, options: .untraced)
    ///
    /// // Combine options
    /// let result = try POSIX.Kernel.Process.Wait.wait(.any, options: [.no.hang, .untraced])
    /// ```
    public struct Options: OptionSet, Sendable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        // MARK: - Nest.Name Pattern for Compound Identifiers

        /// Accessor for `no.hang` (WNOHANG).
        public static var no: No { No() }

        /// No-hang option accessor (Nest.Name pattern).
        public struct No: Sendable {

            public init() {}

            /// Don't block if no child has exited (WNOHANG).
            ///
            /// When specified, `wait` returns `nil` if no child has
            /// changed state, instead of blocking.

            public var hang: Options { Options(rawValue: WNOHANG) }
        }

        // MARK: - Direct Options

        /// Report stopped children (WUNTRACED).
        ///
        /// Also report status for children that are stopped but not
        /// yet reported (traced children stop on any signal).
        public static let untraced = Self(rawValue: WUNTRACED)

        /// Report continued children (WCONTINUED).
        ///
        /// Also report status for children that have been continued
        /// from a stopped state by delivery of SIGCONT.
        public static let continued = Self(rawValue: WCONTINUED)
    }
}
