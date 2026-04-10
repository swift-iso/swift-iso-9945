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

/// ISO 9945 (POSIX) platform namespace.
///
/// Contains POSIX-specific kernel mechanisms including:
/// - Signal handling
/// - Process management (fork, exec, wait)
/// - Memory locking
/// - Dynamic library loading extensions
public enum ISO_9945: Sendable {}

/// Convenience typealias for ISO 9945 (POSIX).
public typealias POSIX = ISO_9945
