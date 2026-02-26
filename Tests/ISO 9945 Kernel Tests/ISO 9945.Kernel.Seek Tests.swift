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
import ISO_9945
import Kernel_Primitives

@testable import ISO_9945_Kernel

extension Kernel.Seek {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Origin Unit Tests

extension Kernel.Seek.Test.Unit {
    @Test("Origin cases are distinct")
    func originCasesDistinct() {
        let start = Kernel.Seek.Origin.start
        let current = Kernel.Seek.Origin.current
        let end = Kernel.Seek.Origin.end

        #expect(start != current)
        #expect(start != end)
        #expect(current != end)
    }

    @Test("Origin is Sendable")
    func originIsSendable() {
        let origin: any Sendable = Kernel.Seek.Origin.start
        #expect(origin is Kernel.Seek.Origin)
    }
}
