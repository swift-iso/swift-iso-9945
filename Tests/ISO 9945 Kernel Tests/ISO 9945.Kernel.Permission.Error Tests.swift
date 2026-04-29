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
import Kernel_File_Primitives
import Path_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension Kernel.Permission.Error {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Permission.Error Tests

extension Kernel.Permission.Error.Test.Unit {
    @Test
    func `denied case exists`() {
        let error = Kernel.Permission.Error.denied
        if case .denied = error {
            // Expected
        } else {
            Issue.record("Expected .denied case")
        }
    }

    @Test
    func `notPermitted case exists`() {
        let error = Kernel.Permission.Error.notPermitted
        if case .notPermitted = error {
            // Expected
        } else {
            Issue.record("Expected .notPermitted case")
        }
    }

    @Test
    func `readOnlyFilesystem case exists`() {
        let error = Kernel.Permission.Error.readOnlyFilesystem
        if case .readOnlyFilesystem = error {
            // Expected
        } else {
            Issue.record("Expected .readOnlyFilesystem case")
        }
    }

    @Test
    func `all cases are distinct`() {
        let denied = Kernel.Permission.Error.denied
        let notPermitted = Kernel.Permission.Error.notPermitted
        let readOnly = Kernel.Permission.Error.readOnlyFilesystem

        #expect(denied != notPermitted)
        #expect(denied != readOnly)
        #expect(notPermitted != readOnly)
    }

    @Test
    func `Permission.Error conforms to Swift.Error`() {
        let error: any Swift.Error = Kernel.Permission.Error.denied
        #expect(error is Kernel.Permission.Error)
    }

    @Test
    func `Permission.Error is Sendable`() {
        let error: any Sendable = Kernel.Permission.Error.denied
        #expect(error is Kernel.Permission.Error)
    }

    @Test
    func `Permission.Error is Equatable`() {
        let a = Kernel.Permission.Error.denied
        let b = Kernel.Permission.Error.denied
        let c = Kernel.Permission.Error.notPermitted

        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Permission.Error is Hashable`() {
        var set = Set<Kernel.Permission.Error>()
        set.insert(.denied)
        set.insert(.notPermitted)
        set.insert(.readOnlyFilesystem)
        set.insert(.denied)  // duplicate

        #expect(set.count == 3)
        #expect(set.contains(.denied))
        #expect(set.contains(.notPermitted))
        #expect(set.contains(.readOnlyFilesystem))
    }

    @Test
    func `denied description is meaningful`() {
        let error = Kernel.Permission.Error.denied
        #expect(error.description == "permission denied")
    }

    @Test
    func `notPermitted description is meaningful`() {
        let error = Kernel.Permission.Error.notPermitted
        #expect(error.description == "operation not permitted")
    }

    @Test
    func `readOnlyFilesystem description is meaningful`() {
        let error = Kernel.Permission.Error.readOnlyFilesystem
        #expect(error.description == "read-only filesystem")
    }
}

extension Kernel.Permission.Error.Test.Unit {
    @Test
    func `CustomStringConvertible works for all cases`() {
        let cases: [Kernel.Permission.Error] = [.denied, .notPermitted, .readOnlyFilesystem]

        for error in cases {
            let description = Swift.String(describing: error)
            #expect(!description.isEmpty, "Description should not be empty for \(error)")
        }
    }
}
