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

import Testing
import ISO_9945_Kernel_Test_Support
import ISO_9945
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

extension Kernel.File.Direct {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Kernel.File.Direct.Test.Unit {
    @Test("Direct namespace exists")
    func namespaceExists() {
        _ = Kernel.File.Direct.self
    }

    @Test("Direct is an enum")
    func isEnum() {
        let _: Kernel.File.Direct.Type = Kernel.File.Direct.self
    }
}

// MARK: - Nested Types

extension Kernel.File.Direct.Test.Unit {
    @Test("Direct.Capability type exists")
    func capabilityTypeExists() {
        let _: Kernel.File.Direct.Capability.Type = Kernel.File.Direct.Capability.self
    }

    @Test("Direct.Mode type exists")
    func modeTypeExists() {
        let _: Kernel.File.Direct.Mode.Type = Kernel.File.Direct.Mode.self
    }

    @Test("Direct.Requirements type exists")
    func requirementsTypeExists() {
        let _: Kernel.File.Direct.Requirements.Type = Kernel.File.Direct.Requirements.self
    }

    @Test("Direct.Error type exists")
    func errorTypeExists() {
        let _: Kernel.File.Direct.Error.Type = Kernel.File.Direct.Error.self
    }
}

// MARK: - Resolved Mode Tests

extension Kernel.File.Direct.Test.Unit {
    @Test("direct mode resolved is equatable")
    func directModeEquatable() {
        #expect(Kernel.File.Direct.Mode.Resolved.buffered == .buffered)
        #expect(Kernel.File.Direct.Mode.Resolved.direct == .direct)
        #expect(Kernel.File.Direct.Mode.Resolved.uncached == .uncached)
        #expect(Kernel.File.Direct.Mode.Resolved.buffered != .direct)
    }

    @Test("requirements known case")
    func requirementsKnownCase() {
        let alignment = Kernel.File.Direct.Requirements.Alignment(uniform: .`4096`)
        let requirements = Kernel.File.Direct.Requirements.known(alignment)

        if case .known(let a) = requirements {
            #expect(a.bufferAlignment == .`4096`)
        } else {
            Issue.record("Expected .known case")
        }
    }

    @Test("requirements unknown case")
    func requirementsUnknownCase() {
        let requirements = Kernel.File.Direct.Requirements.unknown(reason: .platformUnsupported)

        if case .unknown(let reason) = requirements {
            #expect(reason == .platformUnsupported)
        } else {
            Issue.record("Expected .unknown case")
        }
    }
}
