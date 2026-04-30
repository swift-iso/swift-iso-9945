// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// G6.D typealias-via-L3 namespace anchor (per [PLAT-ARCH-005]):
// - Canonical POSIX Kernel type is nested under ISO_9945 (`ISO_9945.Kernel`).
// - swift-kernel L3 declares `public typealias Kernel = ISO_9945.Kernel`
//   per #if-os to provide the unified cross-platform name.
// - swift-kernel-primitives package no longer exists; the Kernel root
//   namespace lives at L2 spec packages.

extension ISO_9945 {
    /// Root namespace for kernel-shaped APIs (POSIX canonical).
    public enum Kernel: Sendable {}
}
