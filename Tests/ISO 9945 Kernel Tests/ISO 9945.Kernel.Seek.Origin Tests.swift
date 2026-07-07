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

import Error_Primitives
import ISO_9945_Kernel_Test_Support
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
// Tests use Apple native Testing framework
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.File.Seek.Origin {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension ISO_9945.Kernel.File.Seek.Origin.Test.Unit {
    @Test
    func `start case exists`() {
        let origin = ISO_9945.Kernel.File.Seek.Origin.start
        if case .start = origin {
            // Expected
        } else {
            Issue.record("Expected .start case")
        }
    }

    @Test
    func `current case exists`() {
        let origin = ISO_9945.Kernel.File.Seek.Origin.current
        if case .current = origin {
            // Expected
        } else {
            Issue.record("Expected .current case")
        }
    }

    @Test
    func `end case exists`() {
        let origin = ISO_9945.Kernel.File.Seek.Origin.end
        if case .end = origin {
            // Expected
        } else {
            Issue.record("Expected .end case")
        }
    }
}

// MARK: - Conformances

extension ISO_9945.Kernel.File.Seek.Origin.Test.Unit {
    @Test
    func `Origin is Sendable`() {
        let origin: any Sendable = ISO_9945.Kernel.File.Seek.Origin.start
        #expect(origin is ISO_9945.Kernel.File.Seek.Origin)
    }
}

// MARK: - Edge Cases

extension ISO_9945.Kernel.File.Seek.Origin.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let start = ISO_9945.Kernel.File.Seek.Origin.start
        let current = ISO_9945.Kernel.File.Seek.Origin.current
        let end = ISO_9945.Kernel.File.Seek.Origin.end

        // Pattern matching confirms distinctness
        switch start {
        case .start:
            break  // expected
        case .current, .end:
            Issue.record("start should not match current or end")
        }

        switch current {
        case .current:
            break  // expected
        case .start, .end:
            Issue.record("current should not match start or end")
        }

        switch end {
        case .end:
            break  // expected
        case .start, .current:
            Issue.record("end should not match start or current")
        }
    }
}

// MARK: - Usage Patterns

extension ISO_9945.Kernel.File.Seek.Origin.Test.Unit {
    @Test
    func `Origin can be used in switch`() {
        func describe(_ origin: ISO_9945.Kernel.File.Seek.Origin) -> Swift.String {
            switch origin {
            case .start: return "beginning"
            case .current: return "current position"
            case .end: return "end"
            }
        }

        #expect(describe(.start) == "beginning")
        #expect(describe(.current) == "current position")
        #expect(describe(.end) == "end")
    }
}
