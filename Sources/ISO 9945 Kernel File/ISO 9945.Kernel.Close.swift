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

// Close implementation moved to L1 (Kernel Descriptor Primitives).
// Kernel.Close.close(_:) is now a consuming function on Kernel.Descriptor
// with deinit as safety net. See Kernel.Close.swift in swift-kernel-primitives.
