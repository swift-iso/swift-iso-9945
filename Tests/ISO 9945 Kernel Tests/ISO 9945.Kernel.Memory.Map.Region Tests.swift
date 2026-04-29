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
import Path_Primitives
import Kernel_Environment_Primitives
import Kernel_Process_Primitives
import Kernel_Thread_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension Memory.Map.Region {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Memory.Map.Region.Test.Unit {
    @Test
    func `Region type exists`() {
        let _: Memory.Map.Region.Type = Memory.Map.Region.self
    }

    @Test
    func `Region is @unchecked Sendable`() {
        // Region contains a raw pointer but is marked @unchecked Sendable
        let _: any Sendable.Type = Memory.Map.Region.self
    }
}

// MARK: - Property Tests

    extension Memory.Map.Region.Test.Unit {
        @Test
        func `Region stores base address`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(System.pageSize)))
            let region = try Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Memory.Map.unmap(region) }

            #expect(region.base != .null)
        }

        @Test
        func `Region stores length`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(System.pageSize)))
            let region = try Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Memory.Map.unmap(region) }

            #expect(region.length == pageSize)
        }

        @Test
        func `Region init sets values correctly`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(System.pageSize)))
            let region = try Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Memory.Map.unmap(region) }

            // Create a new region with same values
            let copy = Memory.Map.Region(base: region.base, length: region.length)
            #expect(copy.base == region.base)
            #expect(copy.length == region.length)
        }
    }

// MARK: - Windows Tests

#if os(Windows)
    extension Memory.Map.Region.Test.Unit {
        @Test
        func `Region stores mappingHandle on Windows`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(System.pageSize)))
            let region = try Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Memory.Map.unmap(region) }

            // The mapping handle should be set
            #expect(region.mappingHandle != nil)
        }
    }
#endif
