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

// NOTE: This file previously contained stat/fstat/lstat implementations.
// Those have been moved to platform-specific packages:
// - POSIX: swift-iso-9945 (ISO_9945.Kernel.File.Stats.get)
// - Windows: swift-windows-primitives (Windows.Kernel.File.Stats.get)
//
// The ISO_9945.Kernel.File.Stats type definition is in ISO_9945.Kernel.File.Stats.swift
