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


// MARK: - Thread Mutex
//
// Mutex implementation is in platform-specific packages:
// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.Thread.Mutex`)
// - Windows: `swift-windows-primitives` (`Windows.Kernel.Thread.Mutex`)
//
// Mutexes require platform-specific storage (pthread_mutex_t / SRWLOCK)
// and initialization/destruction syscalls, so they cannot live in the
// types-only primitives layer.

