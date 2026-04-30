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

// Tests use Apple native Testing framework
import Testing
import ISO_9945_Kernel_Test_Support
import ISO_9945_Kernel
import Kernel_Primitives_Core
import Kernel_Event_Primitives
import Kernel_File_Primitives
import Path_Primitives
import Kernel_Process_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension Kernel.File.Seek {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Origin Unit Tests

extension Kernel.File.Seek.Test.Unit {
    @Test
    func `Origin cases are distinct`() {
        let start = Kernel.File.Seek.Origin.start
        let current = Kernel.File.Seek.Origin.current
        let end = Kernel.File.Seek.Origin.end

        #expect(start != current)
        #expect(start != end)
        #expect(current != end)
    }

    @Test
    func `Origin is Sendable`() {
        let origin: any Sendable = Kernel.File.Seek.Origin.start
        #expect(origin is Kernel.File.Seek.Origin)
    }
}
