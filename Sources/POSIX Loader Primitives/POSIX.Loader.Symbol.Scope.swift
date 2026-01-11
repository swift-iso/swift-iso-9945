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
    internal import CPosixShim
#elseif canImport(Glibc)
    internal import Glibc
    internal import CPosixShim
#elseif canImport(Musl)
    internal import Musl
    internal import CPosixShim
#endif

// MARK: - dlsym Handle Conversion

#if !os(Windows)

extension Loader.Symbol.Scope {
    /// Converts scope to dlsym handle pointer.
    ///
    /// Uses platform constants from dlfcn.h via C shims.
    /// NEVER hardcodes sentinel bit patterns.
    package var dlsymHandle: UnsafeMutableRawPointer? {
        switch self {
        case .handle(let h):
            return h.rawValue
        case .default:
            return swift_RTLD_DEFAULT()
        case .next:
            return swift_RTLD_NEXT()
        }
    }
}

#endif
