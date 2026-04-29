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
import Error_Primitives

@testable import ISO_9945_Kernel

extension Kernel.File.Seek.Origin {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.Seek.Origin.Test.Unit {
    @Test
    func `start case exists`() {
        let origin = Kernel.File.Seek.Origin.start
        if case .start = origin {
            // Expected
        } else {
            Issue.record("Expected .start case")
        }
    }

    @Test
    func `current case exists`() {
        let origin = Kernel.File.Seek.Origin.current
        if case .current = origin {
            // Expected
        } else {
            Issue.record("Expected .current case")
        }
    }

    @Test
    func `end case exists`() {
        let origin = Kernel.File.Seek.Origin.end
        if case .end = origin {
            // Expected
        } else {
            Issue.record("Expected .end case")
        }
    }
}

// MARK: - Conformances

extension Kernel.File.Seek.Origin.Test.Unit {
    @Test
    func `Origin is Sendable`() {
        let origin: any Sendable = Kernel.File.Seek.Origin.start
        #expect(origin is Kernel.File.Seek.Origin)
    }
}

// MARK: - Edge Cases

extension Kernel.File.Seek.Origin.Test.EdgeCase {
    @Test
    func `all cases are distinct`() {
        let start = Kernel.File.Seek.Origin.start
        let current = Kernel.File.Seek.Origin.current
        let end = Kernel.File.Seek.Origin.end

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

extension Kernel.File.Seek.Origin.Test.Unit {
    @Test
    func `Origin can be used in switch`() {
        func describe(_ origin: Kernel.File.Seek.Origin) -> Swift.String {
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
