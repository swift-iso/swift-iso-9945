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

extension ISO_9945.Kernel.Process.Wait {
    /// Options for wait operations.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Non-blocking wait
    /// let result = try ISO_9945.Kernel.Process.Wait.wait(.any, options: .no.hang)
    ///
    /// // Wait for stopped children
    /// let result = try ISO_9945.Kernel.Process.Wait.wait(.any, options: .untraced)
    ///
    /// // Combine options
    /// let result = try ISO_9945.Kernel.Process.Wait.wait(.any, options: [.no.hang, .untraced])
    /// ```
    public struct Options: OptionSet, Sendable, Hashable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        // MARK: - Nest.Name Pattern for Compound Identifiers

        /// Accessor for `no.hang` (WNOHANG).
        public static var no: No { No() }

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

        // MARK: - waitid Options

        /// Wait for children that have exited (WEXITED).
        ///
        /// Used with `waitid`. Reports children that have terminated.
        public static let exited = Self(rawValue: WEXITED)

        /// Wait for children that have been stopped by a signal (WSTOPPED).
        ///
        /// Used with `waitid`. Reports children that have been stopped.
        public static let stopped = Self(rawValue: WSTOPPED)
    }
}
