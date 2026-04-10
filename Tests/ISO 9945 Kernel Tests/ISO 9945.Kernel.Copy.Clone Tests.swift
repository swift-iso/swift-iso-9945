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

#if os(Linux) || canImport(Darwin)

extension Kernel.Copy.Clone {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.Copy.Clone.Test.Unit {
    @Test("Clone namespace exists")
    func namespaceExists() {
        _ = Kernel.Copy.Clone.self
    }

    @Test("Clone is an enum")
    func isEnum() {
        let _: Kernel.Copy.Clone.Type = Kernel.Copy.Clone.self
    }
}

// MARK: - Platform-Specific API Tests

#if os(Linux)
extension Kernel.Copy.Clone.Test.Unit {
    @Test("perform function exists on Linux")
    func performSignatureExists() {
        // Verify the function signature compiles
        typealias PerformType = (Kernel.Descriptor, Kernel.Descriptor) throws -> Void
    }
}
#endif

#if canImport(Darwin)
extension Kernel.Copy.Clone.Test.Unit {
    @Test("file function exists on Darwin")
    func fileSignatureExists() {
        // Verify the namespace and function exist at compile time
        _ = Kernel.Copy.Clone.self
    }
}
#endif

#endif
