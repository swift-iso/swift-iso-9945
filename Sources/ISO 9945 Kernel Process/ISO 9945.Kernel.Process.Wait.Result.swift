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

// MARK: - Result

extension ISO_9945.Kernel.Process.Wait {
    /// Result of a wait operation.
    public struct Result: Sendable, Equatable {
        /// The process ID that changed state.
        public let pid: Kernel.Process.ID

        /// The status of the process.
        public let status: ISO_9945.Kernel.Process.Status

        public init(pid: Kernel.Process.ID, status: ISO_9945.Kernel.Process.Status) {
            self.pid = pid
            self.status = status
        }
    }
}
