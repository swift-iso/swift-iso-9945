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


#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX close() — spec-literal raw

extension ISO_9945.Kernel.Close {
    /// Raw POSIX `close(2)` syscall.
    ///
    /// Spec-literal: takes a file descriptor, returns the C-level result.
    /// Zero policy: NO errno read, NO error mapping, NO throwing.
    ///
    /// **Internal scope only.** Per [PLAT-ARCH-008l] (Wave 4c-deinit-helper,
    /// 2026-05-01), L2 deinit-context APIs use the typed throwing form via
    /// `try?`; raw `(_ fd: Int32) -> Int32` companion forms are not L2 public
    /// surface. The typed form (`close(_:consuming Descriptor)` at `ISO 9945
    /// Core/ISO 9945.Kernel.Close.swift`) inlines libc directly — this raw
    /// form is retained at internal scope for future delegation use.
    ///
    /// - Parameter fd: File descriptor to close.
    /// - Returns: 0 on success, -1 on failure (`errno` set).
    internal static func close(_ fd: Int32) -> Int32 {
        #if canImport(Darwin)
        return Darwin.close(fd)
        #elseif canImport(Glibc)
        return unsafe Glibc.close(fd)
        #elseif canImport(Musl)
        return unsafe Musl.close(fd)
        #else
        return -1
        #endif
    }
}
