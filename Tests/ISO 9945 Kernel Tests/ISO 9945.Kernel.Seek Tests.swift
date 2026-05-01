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
import Path_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.File.Seek {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Origin Unit Tests

extension ISO_9945.Kernel.File.Seek.Test.Unit {
    @Test
    func `Origin cases are distinct`() {
        let start = ISO_9945.Kernel.File.Seek.Origin.start
        let current = ISO_9945.Kernel.File.Seek.Origin.current
        let end = ISO_9945.Kernel.File.Seek.Origin.end

        #expect(start != current)
        #expect(start != end)
        #expect(current != end)
    }

    @Test
    func `Origin is Sendable`() {
        let origin: any Sendable = ISO_9945.Kernel.File.Seek.Origin.start
        #expect(origin is ISO_9945.Kernel.File.Seek.Origin)
    }
}
