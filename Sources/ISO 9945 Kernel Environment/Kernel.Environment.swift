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



extension ISO_9945.Kernel {
    /// Environment variable access using platform-native strings.
    ///
    /// Provides a Swift interface to environment variables using `String`
    /// types. Does not depend on `Swift.String` or Foundation.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.Environment`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.Environment`)
    ///
    /// ## Thread Safety
    ///
    /// Environment variable access is NOT thread-safe at this level.
    /// Higher-level packages (swift-environment) provide synchronized access.
    public enum Environment {}
}

