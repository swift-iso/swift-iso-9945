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

/// Per-package syscall result normalization utilities.
///
/// Per Path X Cycle 4: each L2 package owns its own syscall-declaration
/// framework — there is no shared `swift-syscall-primitives` package.
/// L2 ARE the syscalls level.
///
/// ## Example
///
/// ```swift
/// let fd = try Syscall.require(
///     open(path, flags),
///     .nonNegative,
///     orThrow: Error.current()
/// )
/// ```
public enum Syscall {}

// MARK: - Rule Type

extension Syscall {
    /// A predicate for validating syscall results.
    public struct Rule<T>: Sendable {
        @usableFromInline
        internal let check: @Sendable (T) -> Bool

        @inlinable
        public init(_ check: @escaping @Sendable (T) -> Bool) {
            self.check = check
        }
    }
}

// MARK: - The Single Primitive

extension Syscall {
    /// Validates a syscall result against a rule, throwing on failure.
    ///
    /// The error is constructed only on the failure path via `@autoclosure`,
    /// ensuring that error capture (e.g., `errno`) happens immediately when needed.
    @discardableResult
    @inlinable
    public static func require<E: Swift.Error, T>(
        _ value: T,
        _ rule: Rule<T>,
        orThrow makeError: @autoclosure () -> E
    ) throws(E) -> T {
        guard rule.check(value) else { throw makeError() }
        return value
    }
}

// MARK: - Integer Rules

extension Syscall.Rule where T == Int {
    /// POSIX: result >= 0 means success (read, write, open, etc.)
    public static var nonNegative: Self { .init { $0 >= 0 } }
}

// MARK: - Equatable Rules

extension Syscall.Rule where T: Equatable & Sendable {
    /// Exact match: result == expected means success.
    @inlinable
    public static func equals(_ expected: T) -> Self {
        .init { $0 == expected }
    }

    /// Not equal: result != value means success.
    @inlinable
    public static func not(_ value: T) -> Self {
        .init { $0 != value }
    }
}

// MARK: - Boolean Rules

extension Syscall.Rule where T == Bool {
    /// Boolean is true.
    public static var isTrue: Self { .init { $0 } }
}

// MARK: - Optional Rules (Generic)

extension Syscall.Rule {
    /// Value is not nil.
    @inlinable
    public static func notNil<U>() -> Syscall.Rule<U?> {
        .init { $0 != nil }
    }
}
