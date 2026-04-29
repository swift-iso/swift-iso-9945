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

extension Kernel.Memory.Map {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Map Tests


    extension Kernel.Memory.Map.Test.Unit {
        @Test
        func `anonymous map succeeds`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(Kernel.System.pageSize)))
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            #expect(region.base != .null)
            #expect(region.length == pageSize)
        }

        @Test
        func `map and unmap cycle works`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(Kernel.System.pageSize)))
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)

            // Unmap should succeed
            try Kernel.Memory.Map.unmap(region)

            // Note: Accessing the memory after unmap is undefined behavior,
            // so we can't easily verify the unmap worked other than no error.
        }

        @Test
        func `mapped memory is readable and writable`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(Kernel.System.pageSize)))
            let region = try Kernel.Memory.Map.Anonymous.map(
                length: pageSize,
                protection: .readWrite
            )
            defer { try? Kernel.Memory.Map.unmap(region) }

            // Write to the mapped memory via mutableSpan
            var mutableSpan = region.mutableSpan
            mutableSpan[0] = 42
            mutableSpan[1] = 123

            // Read back via span
            #expect(region.span[0] == 42)
            #expect(region.span[1] == 123)
        }

        @Test
        func `sync succeeds on mapped region`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(Kernel.System.pageSize)))
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            // Sync should succeed (even for anonymous, it's a no-op but shouldn't error)
            try Kernel.Memory.Map.sync(addr: region.base, length: region.length)
        }

        @Test
        func `protect changes memory protection`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(Kernel.System.pageSize)))
            let region = try Kernel.Memory.Map.Anonymous.map(
                length: pageSize,
                protection: .readWrite
            )
            defer { try? Kernel.Memory.Map.unmap(region) }

            // Write some data first
            var mutableSpan = region.mutableSpan
            mutableSpan[0] = 99

            // Change to read-only (should succeed)
            try Kernel.Memory.Map.protect(
                addr: region.base,
                length: region.length,
                protection: .read
            )

            // Reading should still work
            #expect(region.span[0] == 99)

            // Note: Writing would now cause SIGBUS/SIGSEGV, which we can't test safely
        }

        @Test
        func `advise does not throw`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(Kernel.System.pageSize)))
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            // advise is advisory-only and shouldn't throw
            Kernel.Memory.Map.advise(
                addr: region.base,
                length: region.length,
                advice: .normal
            )
        }

        @Test
        func `multi-page mapping works`() throws {
            let multiPageSize = Kernel.File.Size(pages: 4, pageSize: UInt(Int(Kernel.System.pageSize)))
            let region = try Kernel.Memory.Map.Anonymous.map(length: multiPageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            #expect(region.length == multiPageSize)

            // Write to first and last page
            var mutableSpan = region.mutableSpan
            mutableSpan[0] = 1
            let lastIndex = mutableSpan.count - 1
            mutableSpan[lastIndex] = 255

            #expect(region.span[0] == 1)
            #expect(region.span[region.span.count - 1] == 255)
        }

        @Test
        func `Region struct stores base and length`() throws {
            let pageSize = Kernel.File.Size.page(size: UInt(Int(Kernel.System.pageSize)))
            let region = try Kernel.Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Kernel.Memory.Map.unmap(region) }

            // Verify region fields
            #expect(region.base != .null)
            #expect(region.length == pageSize)
        }
    }

    // MARK: - Error Tests

    extension Kernel.Memory.Map.Test.EdgeCase {
        @Test
        func `map with zero length throws`() {
            #expect(throws: Kernel.Memory.Map.Error.self) {
                _ = try Kernel.Memory.Map.Anonymous.map(length: .zero)
            }
        }

        @Test
        func `map with zero length throws invalid length error`() {
            do {
                _ = try Kernel.Memory.Map.Anonymous.map(length: .zero)
                Issue.record("Expected error to be thrown")
            } catch {
                if case .invalid(.length) = error {
                    // Expected
                } else {
                    Issue.record("Expected .invalid(.length), got \(error)")
                }
            }
        }
    }

