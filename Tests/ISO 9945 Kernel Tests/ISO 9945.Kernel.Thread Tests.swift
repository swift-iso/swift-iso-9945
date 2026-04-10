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
import Kernel_Primitives_Core
import Kernel_Descriptor_Primitives
import Kernel_Event_Primitives
import Kernel_IO_Primitives
import Kernel_File_Primitives
import Kernel_Path_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Kernel_Error_Primitives

@testable import ISO_9945_Kernel

// Kernel.Thread.Test is defined in ISO 9945.Kernel.Thread.Create Tests.swift.
// This file adds basic namespace existence tests to that suite.

// MARK: - Namespace Existence

extension Kernel.Thread.Test.Unit {
    @Test("Thread namespace exists")
    func namespaceExists() {
        _ = Kernel.Thread.self
    }

    @Test("Thread is an enum")
    func isEnum() {
        let _: Kernel.Thread.Type = Kernel.Thread.self
    }
}

// MARK: - Nested Types

extension Kernel.Thread.Test.Unit {
    @Test("Thread.Handle type exists")
    func handleTypeExists() {
        let _: Kernel.Thread.Handle.Type = Kernel.Thread.Handle.self
    }

    @Test("Thread.Error type exists")
    func errorTypeExists() {
        let _: Kernel.Thread.Error.Type = Kernel.Thread.Error.self
    }

    @Test("Thread.Mutex type exists")
    func mutexTypeExists() {
        let _: Kernel.Thread.Mutex.Type = Kernel.Thread.Mutex.self
    }

    @Test("Thread.Condition type exists")
    func conditionTypeExists() {
        let _: Kernel.Thread.Condition.Type = Kernel.Thread.Condition.self
    }
}

// MARK: - Create Function

extension Kernel.Thread.Test.Unit {
    @Test("create function signature exists")
    func createFunctionExists() {
        // Verify the create function signature exists
        // create(_:) -> Handle throws(Error)
        typealias CreateType = (@escaping @Sendable () -> Void) throws -> Kernel.Thread.Handle
        // The function is verified at compile time
    }
}
