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

// MARK: - POSIX random namespace anchor
//
// Re-declares the empty `Kernel.Random` namespace at L2 so that platform
// syscall extensions (`Linux.Kernel.Random.getrandom`,
// `Darwin.Kernel.Random.arc4random`) compile against a fresh namespace
// shell after the L1 `swift-kernel-primitives` Kernel Random Primitives
// target was removed in Path X Cycle 7. Per `Random.Error` the canonical
// throwable type is `Random_Primitives.Random.Error`; this namespace is
// purely an extension host for platform-specific syscall wrappers.

extension Kernel {
    public enum Random {}
}
