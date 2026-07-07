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

// MARK: - Environment Entries Iterator
//
// Environment entries iterator implementation is in platform-specific packages:
// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.Environment.Entries`)
// - Windows: `swift-windows-primitives` (`Windows.Kernel.Environment.Entries`)
//
// Environment iteration requires platform-specific access (environ / GetEnvironmentStringsW),
// so it cannot live in the types-only primitives layer.
