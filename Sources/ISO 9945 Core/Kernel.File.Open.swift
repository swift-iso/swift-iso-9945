// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.File {
    /// File open operations and configuration types.
    ///
    /// Provides the fundamental `open()` syscall for creating or opening files.
    /// Returns a raw ``Kernel/Descriptor`` that must be closed explicitly via
    /// ``Kernel/Close/close(_:)``.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations and types are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945_Kernel`)
    ///   - `ISO_9945.Kernel.File.Open.Mode` - O_RDONLY, O_WRONLY, O_RDWR
    ///   - `ISO_9945.Kernel.File.Open.Options` - O_CREAT, O_TRUNC, etc.
    ///   - `ISO_9945.Kernel.File.Open.open()` - POSIX open() syscall
    ///
    /// ## See Also
    /// - ``Kernel/File/Permissions``
    public struct Open {}
}
