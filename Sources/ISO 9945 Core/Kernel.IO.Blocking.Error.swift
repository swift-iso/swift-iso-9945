// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


extension ISO_9945.Kernel.IO.Blocking {
    /// Blocking-related errors.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Operation would block on a non-blocking descriptor.
        /// - POSIX: `EAGAIN`, `EWOULDBLOCK`
        ///
        /// The caller should wait for the descriptor to become ready
        /// (e.g., via poll/select/kqueue/epoll) and retry.
        case wouldBlock
    }
}

// MARK: - CustomStringConvertible

extension ISO_9945.Kernel.IO.Blocking.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .wouldBlock:
            return "operation would block"
        }
    }
}

// MARK: - Platform Bindings
//
// Per [PLAT-ARCH-008c], the platform-specific `var code` accessor and
// `init?(code:)` mapping live in L2:
// - POSIX: `swift-iso-9945` (`ISO 9945.Kernel.IO.Blocking.Error+code.swift`)
// - Windows: blocking errors are POSIX-only; no Windows binding.

