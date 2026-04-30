// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


// MARK: - Typed Pointer Arithmetic

extension UnsafeMutableRawPointer {
    /// Returns a pointer offset by the given file size.
    ///
    /// - Parameter size: The byte offset as a typed file size.
    /// - Returns: A pointer advanced by the size's byte count.
    @inlinable
    @unsafe
    public func advanced(by size: ISO_9945.Kernel.File.Size) -> UnsafeMutableRawPointer {
        unsafe advanced(by: Int(size))
    }
}

extension UnsafeRawPointer {
    /// Returns a pointer offset by the given file size.
    ///
    /// - Parameter size: The byte offset as a typed file size.
    /// - Returns: A pointer advanced by the size's byte count.
    @inlinable
    @unsafe
    public func advanced(by size: ISO_9945.Kernel.File.Size) -> UnsafeRawPointer {
        unsafe advanced(by: Int(size))
    }
}

