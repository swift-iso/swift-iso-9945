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
import Testing

@testable import ISO_9945_Kernel

extension Kernel.Signal {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

// MARK: - Unit Tests

extension Kernel.Signal.Test.Unit {
    @Test("Signal namespace exists")
    func namespaceExists() {
        _ = Kernel.Signal.self
    }

    @Test("Signal is an enum")
    func isEnum() {
        let _: Kernel.Signal.Type = Kernel.Signal.self
    }
}

// MARK: - Nested Types

extension Kernel.Signal.Test.Unit {
    #if canImport(Darwin) || canImport(Glibc) || canImport(Musl)
        @Test("Signal.Error type exists")
        func errorTypeExists() {
            let _: Kernel.Signal.Error.Type = Kernel.Signal.Error.self
        }
    #endif
}
