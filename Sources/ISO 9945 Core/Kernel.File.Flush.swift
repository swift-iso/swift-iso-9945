// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//



extension ISO_9945.Kernel.File {
    /// File flush (synchronization) operations.
    ///
    /// Provides fsync functionality for durably persisting file data to storage.
    ///
    /// Wraps POSIX `fsync()` / Windows `FlushFileBuffers()`.
    ///
    /// ## Platform Implementation
    ///
    /// Syscall implementations are in platform-specific packages:
    /// - POSIX: `swift-posix-primitives` (`Posix.Kernel.File.Flush`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.File.Flush`)
    public enum Flush: Sendable {}
}

// MARK: - Error

extension ISO_9945.Kernel.File.Flush {
    /// Errors that can occur during file flush operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The file descriptor is invalid.
        case handle(ISO_9945.Kernel.Descriptor.Validity.Error)

        /// Platform-specific error.
        case platform(Error_Primitives.Error)
    }
}

extension ISO_9945.Kernel.File.Flush.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .handle(let e): return "handle: \(e)"
        case .platform(let e): return "\(e)"
        }
    }
}

// MARK: - Platform Bindings
//
// Per [PLAT-ARCH-008c], the platform-specific `var code` accessor lives in L2:
// - POSIX: `swift-iso-9945` (`ISO 9945.Kernel.File.Flush.Error+code.swift`)
// - Windows: `swift-windows-standard` (`Windows.Kernel.File.Flush.Error+code.swift`)

