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

// MARK: - POSIX Conformance

// POSIX path separator: '/' (U+002F).
//
// Decomposition delegates to `Path.Scan.lastSeparatorIndex` for the byte
// scan; branching (root handling, sub-span construction) is POSIX-specific
// and lives here. Appending inserts a single separator between `view` and
// `other` unless `view` already ends with one.

extension Path.View: @retroactive Path.`Protocol` {
    public typealias Char = Path.Char

    @inlinable
    @_lifetime(copy view)
    public static func parent(of view: borrowing Path.View) -> Span<Path.Char>? {
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
    public static func component(of view: borrowing Path.View) -> Span<Path.Char> {
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

    @inlinable
    public static func appending(
        _ view: borrowing Path.View,
        _ other: borrowing Path.View
    ) -> Path {
        let selfEndsWithSep: Bool = if view.count > 0 {
            unsafe view.pointer[view.count - 1] == 0x2F
        } else {
            false
        }
        let separatorSize = selfEndsWithSep ? 0 : 1
        let totalCount = view.count + separatorSize + other.count

        let buffer = UnsafeMutablePointer<Path.Char>.allocate(capacity: totalCount + 1)
        unsafe buffer.initialize(from: view.pointer, count: view.count)
        var offset = view.count
        if !selfEndsWithSep {
            (unsafe buffer)[offset] = 0x2F
            offset += 1
        }
        unsafe (buffer + offset).initialize(from: other.pointer, count: other.count)
        (unsafe buffer)[totalCount] = 0

        return unsafe Path(adopting: buffer, count: totalCount)
    }
}
