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

@_spi(Syscall) import Kernel_Descriptor_Primitives

#if canImport(Darwin)
    internal import Darwin
    internal import CPOSIXProcessShim
#elseif canImport(Glibc)
    internal import Glibc
    internal import CPOSIXProcessShim
#elseif canImport(Musl)
    internal import Musl
    internal import CPOSIXProcessShim
#endif

extension ISO_9945.Kernel.Process {
    /// Exit status from wait operations.
    ///
    /// Wraps the raw status integer with typed accessors.
    /// All accessors use POSIX macros (via C shim wrappers), not bit manipulation.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let result = try ISO_9945.Kernel.Process.Wait.wait(.any)
    /// if result.status.exited {
    ///     print("Exit code: \(result.status.exit.code ?? 0)")
    /// }
    /// ```
    public struct Status: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Boolean Status Checks

extension ISO_9945.Kernel.Process.Status {
    /// Whether process exited normally (WIFEXITED).
    public var exited: Bool {
        swift_WIFEXITED(rawValue) != 0
    }

    /// Whether process was terminated by signal (WIFSIGNALED).
    public var signaled: Bool {
        swift_WIFSIGNALED(rawValue) != 0
    }

    /// Whether process was stopped (WIFSTOPPED).
    public var stopped: Bool {
        swift_WIFSTOPPED(rawValue) != 0
    }

    /// Whether process was continued (WIFCONTINUED).
    public var continued: Bool {
        swift_WIFCONTINUED(rawValue) != 0
    }
}

// MARK: - Nest.Name Accessors

extension ISO_9945.Kernel.Process.Status {
    /// Nested accessor for exit code info.
    public var exit: Exit { Exit(self) }

    /// Nested accessor for terminating signal info.
    public var terminating: Terminating { Terminating(self) }

    /// Nested accessor for stop signal info.
    public var stop: Stop { Stop(self) }

    /// Nested accessor for core dump info.
    public var core: Core { Core(self) }
}
