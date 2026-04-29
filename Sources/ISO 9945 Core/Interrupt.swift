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

/// Semantic representation of operation interruption.
///
/// Per Path X Cycle 3: POSIX-specific `EINTR` interruption lives at L2
/// (this package, iso-9945). Windows has no equivalent. Each L2 package
/// owns its own syscall-framework machinery — there is no shared
/// `swift-outcome-primitives` package.
///
/// ## Usage
///
/// Surfaced via `Either<DomainError, Interrupt>` typed-throw payload.
public enum Interrupt: Swift.Error, Sendable, Hashable {
    /// Operation was interrupted by an external condition.
    ///
    /// On POSIX: Maps from `EINTR` (syscall interrupted by signal).
    /// Retry typically succeeds.
    case occurred

    /// Operation was cancelled due to lifecycle/shutdown.
    ///
    /// Distinct from `.occurred` in that retry is not appropriate.
    /// The cancellation is intentional, not environmental.
    case cancelled
}

// MARK: - CustomStringConvertible

extension Interrupt: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .occurred:
            return "interrupted"
        case .cancelled:
            return "cancelled"
        }
    }
}
