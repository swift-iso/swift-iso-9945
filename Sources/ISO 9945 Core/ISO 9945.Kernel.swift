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


public import Kernel_Namespace

extension ISO_9945 {
    /// ISO 9945 (POSIX) kernel mechanisms.
    ///
    /// Typealias to `Kernel_Namespace.Kernel`, allowing POSIX-specific
    /// extensions to be added to the shared Kernel type.
    public typealias Kernel = Kernel_Namespace.Kernel
}
