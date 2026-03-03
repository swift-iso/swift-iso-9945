// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// MARK: - ISO_9945.ABI: POSIX C ABI Projection
//
// This module contains ONLY the ABI projection law for ISO_9945:
//
//   "In ISO_9945, our semantic code unit is UInt8 (via Path.Char).
//    When calling POSIX C APIs, we project UnsafePointer<UInt8> ↔ UnsafePointer<CChar>."
//
// This is not a utility module. It defines the formal boundary contract between
// Swift's semantic types and the POSIX C ABI.
//
// ALLOWED: pointer projection initializers, marker types for ABI facts
// FORBIDDEN: syscalls, allocation, policy, string construction, error mapping

#if canImport(Darwin) || canImport(Glibc) || canImport(Musl)

// MARK: - UInt8 → CChar Projection (for calling C APIs)

extension UnsafePointer where Pointee == CChar {
    /// Projects a `UInt8` pointer as a `CChar` pointer for syscall use.
    ///
    /// This is a zero-cost reinterpretation, not a conversion. `UInt8` and `CChar`
    /// have identical memory layout.
    @inlinable
    @unsafe
    package init(_ pointer: UnsafePointer<UInt8>) {
        self = unsafe UnsafeRawPointer(pointer).assumingMemoryBound(to: CChar.self)
    }
}

extension UnsafeMutablePointer where Pointee == CChar {
    /// Projects a mutable `UInt8` pointer as a mutable `CChar` pointer for syscall use.
    @inlinable
    @unsafe
    package init(_ pointer: UnsafeMutablePointer<UInt8>) {
        self = unsafe UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: CChar.self)
    }
}

// MARK: - CChar → UInt8 Projection (for reading from C APIs)

extension UnsafePointer where Pointee == UInt8 {
    /// Projects a `CChar` pointer as a `UInt8` pointer when reading from C APIs.
    ///
    /// Use this when receiving pointers from C functions (like `environ`, `readdir`, etc.)
    /// that return `CChar*` but need to be accessed as `UInt8*` (the canonical Swift type).
    @inlinable
    @unsafe
    package init(_ pointer: UnsafePointer<CChar>) {
        self = unsafe UnsafeRawPointer(pointer).assumingMemoryBound(to: UInt8.self)
    }
}

extension UnsafeMutablePointer where Pointee == UInt8 {
    /// Projects a mutable `CChar` pointer as a mutable `UInt8` pointer.
    @inlinable
    @unsafe
    package init(_ pointer: UnsafeMutablePointer<CChar>) {
        self = unsafe UnsafeMutableRawPointer(pointer).assumingMemoryBound(to: UInt8.self)
    }
}

#endif // canImport(Darwin) || canImport(Glibc) || canImport(Musl)
