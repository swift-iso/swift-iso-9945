// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.Process.Spawn.Actions {
    /// A slot in the child process's file-descriptor table.
    ///
    /// `Target` names a slot — typically a stdio slot (0 = stdin, 1 = stdout,
    /// 2 = stderr) — that the child will see after `posix_spawn(3)`. It is the
    /// destination of a ``add(dup2:to:)`` action or the slot a
    /// ``add(close:)`` action closes.
    ///
    /// A `Target` is not an owned descriptor: it does not close on drop. It
    /// records *which fd number* the child will manipulate.
    public struct Target: Sendable, Equatable, Hashable {
        @usableFromInline
        internal let _raw: Int32

        @inlinable
        package init(_raw: Int32) {
            self._raw = _raw
        }

        /// A target naming the same fd number as `descriptor`.
        ///
        /// In the child, descriptor numbers initially mirror the parent
        /// (until a `dup2` or `close` action changes them). This init lets
        /// the caller name a parent-owned descriptor's slot for use in
        /// ``add(close:)``.
        public init(_ descriptor: borrowing ISO_9945.Kernel.Descriptor) {
            self._raw = descriptor._raw
        }
    }
}

extension ISO_9945.Kernel.Process.Spawn.Actions.Target {
    /// The child's standard input slot (fd 0).
    public static let stdin = Self(_raw: 0)

    /// The child's standard output slot (fd 1).
    public static let stdout = Self(_raw: 1)

    /// The child's standard error slot (fd 2).
    public static let stderr = Self(_raw: 2)
}
