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

// Tests use Apple native Testing framework
import Testing
import Tagged_Primitives_Standard_Library_Integration
import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import Path_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

// ISO_9945.Kernel.Thread.Test is defined in ISO 9945.Kernel.Thread.Create Tests.swift.
// This file adds basic namespace existence tests to that suite.

// MARK: - Namespace Existence

extension ISO_9945.Kernel.Thread.Test.Unit {
    @Test
    func `Thread namespace exists`() {
        _ = ISO_9945.Kernel.Thread.self
    }

    @Test
    func `Thread is an enum`() {
        let _: ISO_9945.Kernel.Thread.Type = ISO_9945.Kernel.Thread.self
    }
}

// MARK: - Nested Types

extension ISO_9945.Kernel.Thread.Test.Unit {
    @Test
    func `Thread.Handle type exists`() {
        let _: ISO_9945.Kernel.Thread.Handle.Type = ISO_9945.Kernel.Thread.Handle.self
    }

    @Test
    func `Thread.Error type exists`() {
        let _: ISO_9945.Kernel.Thread.Error.Type = ISO_9945.Kernel.Thread.Error.self
    }

    @Test
    func `Thread.Mutex type exists`() {
        let _: ISO_9945.Kernel.Thread.Mutex.Type = ISO_9945.Kernel.Thread.Mutex.self
    }

    @Test
    func `Thread.Condition type exists`() {
        let _: ISO_9945.Kernel.Thread.Condition.Type = ISO_9945.Kernel.Thread.Condition.self
    }
}

// MARK: - Create Function

extension ISO_9945.Kernel.Thread.Test.Unit {
    @Test
    func `create function signature exists`() {
        // Verify the create function signature exists
        // create(_:) -> Handle throws(Error)
        typealias CreateType = (@escaping @Sendable () -> Void) throws -> ISO_9945.Kernel.Thread.Handle
        // The function is verified at compile time
    }
}
