// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-loader open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-loader project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Loader_Primitives
public import POSIX_Primitives

#if canImport(Darwin)
    internal import Darwin
    internal import Kernel_Primitives
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Loader.Library {
    /// Options for loading dynamic libraries.
    ///
    /// Maps to RTLD_* flags on POSIX.
    public struct Options: OptionSet, Sendable, Hashable {
        public let rawValue: Int32

        @inlinable
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Standard Options (POSIX only)

#if canImport(Darwin) || canImport(Glibc) || canImport(Musl)

extension ISO_9945.Loader.Library.Options {
    /// Resolve symbols lazily (RTLD_LAZY).
    ///
    /// Defers symbol resolution until first use; may hide errors
    /// until the unresolved symbol is actually called.
    public static let lazy = Self(rawValue: RTLD_LAZY)

    /// Resolve all symbols immediately (RTLD_NOW).
    ///
    /// Fails at load if any symbol is unresolved.
    /// **This is the default** — aligns with "fail early" philosophy.
    public static let now = Self(rawValue: RTLD_NOW)

    /// Symbols not available to subsequently loaded libraries (RTLD_LOCAL).
    ///
    /// This is the default behavior on most systems.
    public static let local = Self(rawValue: RTLD_LOCAL)

    /// Symbols available globally (RTLD_GLOBAL).
    ///
    /// Symbols from this library are available for symbol resolution
    /// of subsequently loaded libraries.
    public static let global = Self(rawValue: RTLD_GLOBAL)
}

#endif

// MARK: - Darwin-Only Options

#if canImport(Darwin)

extension ISO_9945.Loader.Library.Options {
    /// Don't load, just check if loadable (RTLD_NOLOAD).
    ///
    /// Returns the handle if the library is already loaded,
    /// or fails without loading. Useful for probing.
    public static let noLoad = Self(rawValue: RTLD_NOLOAD)

    /// Don't delete on close (RTLD_NODELETE).
    ///
    /// Keeps the library in memory even after `close`.
    /// The library's static destructors will not run.
    public static let noDelete = Self(rawValue: RTLD_NODELETE)
}

#endif
