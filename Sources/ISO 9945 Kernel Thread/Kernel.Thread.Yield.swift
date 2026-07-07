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

// MARK: - Thread Yield
//
// Thread yield syscall is in platform-specific packages:
// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.Thread.yield()`)
// - Windows: `swift-windows-primitives` (`ISO_9945.Kernel.Thread.yield()`)
