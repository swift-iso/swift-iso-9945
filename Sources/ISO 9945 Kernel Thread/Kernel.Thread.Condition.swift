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


// MARK: - Thread Condition Variable
//
// Condition variable implementation is in platform-specific packages:
// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.Thread.Condition`)
// - Windows: `swift-windows-primitives` (`Windows.Kernel.Thread.Condition`)
//
// Condition variables require platform-specific storage (pthread_cond_t / CONDITION_VARIABLE)
// and initialization/destruction syscalls, so they cannot live in the
// types-only primitives layer.

