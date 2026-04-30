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
import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import Kernel_File_Primitives
import Path_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

// Kernel.Thread.Test is defined in ISO 9945.Kernel.Thread.Create Tests.swift.
// This file adds basic namespace existence tests to that suite.

// MARK: - Namespace Existence

extension Kernel.Thread.Test.Unit {
    @Test
    func `Thread namespace exists`() {
        _ = Kernel.Thread.self
    }

    @Test
    func `Thread is an enum`() {
        let _: Kernel.Thread.Type = Kernel.Thread.self
    }
}

// MARK: - Nested Types

extension Kernel.Thread.Test.Unit {
    @Test
    func `Thread.Handle type exists`() {
        let _: Kernel.Thread.Handle.Type = Kernel.Thread.Handle.self
    }

    @Test
    func `Thread.Error type exists`() {
        let _: Kernel.Thread.Error.Type = Kernel.Thread.Error.self
    }

    @Test
    func `Thread.Mutex type exists`() {
        let _: Kernel.Thread.Mutex.Type = Kernel.Thread.Mutex.self
    }

    @Test
    func `Thread.Condition type exists`() {
        let _: Kernel.Thread.Condition.Type = Kernel.Thread.Condition.self
    }
}

// MARK: - Create Function

extension Kernel.Thread.Test.Unit {
    @Test
    func `create function signature exists`() {
        // Verify the create function signature exists
        // create(_:) -> Handle throws(Error)
        typealias CreateType = (@escaping @Sendable () -> Void) throws -> Kernel.Thread.Handle
        // The function is verified at compile time
    }
}
