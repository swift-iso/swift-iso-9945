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

extension ISO_9945.Kernel.File.Direct.Mode {
    /// The resolved mode after platform-specific evaluation.
    ///
    /// This represents the actual mode that will be used, after `.auto`
    /// policies have been resolved for the current platform.
    public enum Resolved: Sendable, Equatable {
        /// Strict Direct I/O is active.
        case direct

        /// Best-effort uncached mode is active (macOS).
        case uncached

        /// Normal buffered I/O is active.
        case buffered
    }
}
