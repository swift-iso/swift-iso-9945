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
public import ISO_9945

extension ISO_9945 {
    /// POSIX dynamic loader interface.
    ///
    /// Provides access to `dlopen`/`dlsym`/`dlclose` functionality
    /// on POSIX-compliant systems (Darwin, Linux).
    ///
    /// Aliases to `Loader` from swift-loader-primitives.
    ///
    /// ## Design
    ///
    /// POSIX.Loader is organized into:
    /// - `POSIX.Loader.Symbol` - dlsym-based symbol lookup
    /// - `POSIX.Loader.Library` - dlopen/dlclose
    ///
    /// ## Semantic Correctness
    ///
    /// These APIs are userspace loader interfaces, NOT kernel syscalls.
    /// They are implemented by:
    /// - libSystem.B.dylib / dyld on Darwin
    /// - libdl.so / ld.so on Linux
    ///
    /// Therefore, they belong in `Loader`, NOT `Kernel`.
    public typealias Loader = Loader_Primitives.Loader
}
