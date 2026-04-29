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
import Kernel_Process_Primitives
import Error_Primitives

@testable import ISO_9945_Kernel

extension Memory.Map.Anonymous {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit Tests

extension Memory.Map.Anonymous.Test.Unit {
    @Test
    func `Anonymous namespace exists`() {
        _ = Memory.Map.Anonymous.self
    }

    @Test
    func `Anonymous is an enum`() {
        let _: Memory.Map.Anonymous.Type = Memory.Map.Anonymous.self
    }
}

// MARK: - Functional Tests

    extension Memory.Map.Anonymous.Test.Unit {
        @Test
        func `map creates a valid region`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(System.pageSize)))
            let region = try Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Memory.Map.unmap(region) }

            #expect(region.base != .null)
            #expect(region.length == pageSize)
        }

        @Test
        func `map with custom protection`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(System.pageSize)))
            let region = try Memory.Map.Anonymous.map(
                length: pageSize,
                protection: .read
            )
            defer { try? Memory.Map.unmap(region) }

            #expect(region.base != .null)
        }

        @Test
        func `map private by default`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(System.pageSize)))
            let region = try Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Memory.Map.unmap(region) }

            // Should succeed (private is default)
            #expect(region.base != .null)
        }

        @Test
        func `map shared when specified`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(System.pageSize)))
            let region = try Memory.Map.Anonymous.map(
                length: pageSize,
                shared: true
            )
            defer { try? Memory.Map.unmap(region) }

            #expect(region.base != .null)
        }
    }

// MARK: - Windows Tests

#if os(Windows)
    extension Memory.Map.Anonymous.Test.Unit {
        @Test
        func `map creates a valid region on Windows`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(System.pageSize)))
            let region = try Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Memory.Map.unmap(region) }

            #expect(region.base != nil)
            #expect(region.length == pageSize)
        }
    }
#endif
