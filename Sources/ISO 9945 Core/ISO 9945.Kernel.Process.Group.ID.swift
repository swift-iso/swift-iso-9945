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

public import Tagged_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Process.Group.ID

extension ISO_9945.Kernel.Process.Group {
    /// POSIX process group ID.
    ///
    /// A type-safe wrapper for process group identifiers used in signal sending.
    ///
    /// Distinct from `Process.ID` to prevent accidentally passing a PGID
    /// where a PID is required (or vice versa).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Send signal to a process group
    /// try ISO_9945.Kernel.Signal.Send.toGroup(.terminate, pgid: .current)
    /// ```
    public typealias ID = Tagged<ISO_9945.Kernel.Process.Group, Int32>
}

// MARK: - Process.Group.ID Constants

extension Tagged where Tag == ISO_9945.Kernel.Process.Group, Underlying == Int32 {
    // Process groups are a POSIX concept with no Win32 analogue (`getpgrp`
    // has no CRT counterpart; Windows job objects are a different model,
    // owned by swift-windows-standard). The ID type itself stays available
    // on Windows; only the live accessor is POSIX-gated.
    #if !os(Windows)
        /// The current process group.

        public static var current: Self { Self(_unchecked: getpgrp()) }
    #endif
}
