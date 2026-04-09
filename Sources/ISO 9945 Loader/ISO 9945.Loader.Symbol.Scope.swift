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

import Loader_Primitives
import ISO_9945  // For ISO_9945.Loader typealias

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

#if canImport(CISO9945Shim)
    internal import CISO9945Shim
#endif

// MARK: - dlsym Handle Conversion

#if !os(Windows)

extension ISO_9945.Loader.Symbol.Scope {
    /// Converts scope to dlsym handle pointer.
    ///
    /// Uses platform constants from dlfcn.h via C shims.
    /// NEVER hardcodes sentinel bit patterns.
    @unsafe
    package var dlsymHandle: UnsafeMutableRawPointer? {
        switch unsafe self {
        case .handle(let h):
            return unsafe h.rawValue
        case .default:
            return unsafe iso9945_RTLD_DEFAULT()
        case .next:
            return unsafe iso9945_RTLD_NEXT()
        }
    }
}

#endif
