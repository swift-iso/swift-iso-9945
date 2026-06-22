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

// MARK: - POSIX Decomposition Conformance

// POSIX path separator: '/' (U+002F).
//
// parent and component delegate to `Path.Scan.lastSeparatorIndex` for the
// byte scan; branching (root handling, sub-span construction) is POSIX-specific
// and lives here. See `ISO 9945.Path.Borrowed+Path.Modification.swift`
// for the appending half of the split.

extension Path.Borrowed: @retroactive Path.Decomposition {
    public typealias Char = Path.Char

    @inlinable
    @_lifetime(copy view)
    public static func parent(of view: borrowing Path.Borrowed) -> Swift.Span<Path.Char>? {
        guard let lastSep = Path.Scan.lastSeparatorIndex(
            in: view.span,
            primary: 0x2F
        ) else { return nil }
        // Root "/" — parent of the root is the root itself, but we return
        // nil to signal "no further parent exists."
        if lastSep == 0 && view.count == 1 { return nil }
        // Separator at index 0 with content after → parent is the root "/"
        // (1 byte: the leading separator).
        let parentCount = lastSep == 0 ? 1 : lastSep
        return unsafe _overrideLifetime(
            Span(_unsafeStart: view.pointer, count: parentCount),
            copying: view
        )
    }

    @inlinable
    @_lifetime(copy view)
    public static func component(of view: borrowing Path.Borrowed) -> Swift.Span<Path.Char> {
        guard let lastSep = Path.Scan.lastSeparatorIndex(
            in: view.span,
            primary: 0x2F
        ) else {
            // No separator → full view is the component.
            return unsafe _overrideLifetime(
                Span(_unsafeStart: view.pointer, count: view.count),
                copying: view
            )
        }
        let offset = lastSep + 1
        return unsafe _overrideLifetime(
            Span(_unsafeStart: view.pointer + offset, count: view.count - offset),
            copying: view
        )
    }
}
