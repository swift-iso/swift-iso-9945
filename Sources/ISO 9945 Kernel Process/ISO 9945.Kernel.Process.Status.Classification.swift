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

// MARK: - Typed Classification

extension ISO_9945.Kernel.Process.Status {
    /// Typed classification for pattern matching.
    ///
    /// Derived from raw accessors — no information loss.
    /// Returns `nil` if status doesn't match any known classification.
    public enum Classification: Sendable, Equatable {
        /// Process exited normally with exit code.
        case exited(code: Int32)

        /// Process terminated by signal.
        ///
        /// The unlabeled `Bool` indicates whether a core dump was produced.
        /// Use `status.core.dumped` for the same value.
        case signaled(signal: ISO_9945.Kernel.Signal.Number, Bool)

        /// Process stopped by signal.
        case stopped(signal: ISO_9945.Kernel.Signal.Number)

        /// Process continued.
        case continued
    }

    /// Classifies the status for pattern matching.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// switch status.classification {
    /// case .exited(let code):
    ///     print("Exited with code \(code)")
    /// case .signaled(let signal, let core):
    ///     print("Killed by \(signal), core: \(core)")
    /// case .stopped(let signal):
    ///     print("Stopped by \(signal)")
    /// case .continued:
    ///     print("Continued")
    /// case nil:
    ///     print("Unknown status")
    /// }
    /// ```
    public var classification: Classification? {
        if exited, let code = exit.code {
            return .exited(code: code)
        }
        if signaled, let signal = terminating.signal {
            return .signaled(signal: signal, core.dumped)
        }
        if stopped, let signal = stop.signal {
            return .stopped(signal: signal)
        }
        if continued {
            return .continued
        }
        return nil
    }
}
