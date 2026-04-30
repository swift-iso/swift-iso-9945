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


#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Process.Wait.Options {
    /// No-hang option accessor (Nest.Name pattern).
    public struct No: Sendable {

        public init() {}

        /// Don't block if no child has exited (WNOHANG).
        ///
        /// When specified, `wait` returns `nil` if no child has
        /// changed state, instead of blocking.

        public var hang: ISO_9945.Kernel.Process.Wait.Options { ISO_9945.Kernel.Process.Wait.Options(rawValue: WNOHANG) }

        /// Do not remove the child from the waitable set (WNOWAIT).
        ///
        /// Used with `waitid`. Leaves the child in a waitable state so that
        /// a subsequent wait call can be used to retrieve the status again.
        public var wait: ISO_9945.Kernel.Process.Wait.Options { ISO_9945.Kernel.Process.Wait.Options(rawValue: WNOWAIT) }
    }
}
