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


extension ISO_9945 {
    /// ISO 9945 (POSIX) kernel mechanisms — typealias to the local
    /// `Kernel` namespace declared at iso-9945 L2 (G6.D parallel roots).
    public typealias Kernel = ISO_9945_Core.Kernel
}
