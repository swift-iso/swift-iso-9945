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

// Kernel.File.Size is a typealias to Magnitude<Space>.Value<Int64>
// Test struct pattern cannot be used on typealiases

@Suite("Kernel.File.Size Tests")
struct FileSizeTests {

    // MARK: - Basic Initialization

    @Test
    func `Size from integer literal`() {
        let size: Kernel.File.Size = 4096
        #expect(size == 4096)
    }

    @Test
    func `Size from Int`() {
        let size = Kernel.File.Size(100)
        #expect(size == 100)
    }

    @Test
    func `Size from Int64`() {
        let size = Kernel.File.Size(Int64(5000))
        #expect(size == 5000)
    }

    @Test
    func `Size from UInt64`() {
        let size = Kernel.File.Size(UInt64(8192))
        #expect(size == 8192)
    }

    @Test
    func `Size from pages`() {
        let pageSizeBytes = UInt(Int(System.pageSize))
        let size = Kernel.File.Size(pages: 2, pageSize: pageSizeBytes)
        let expectedBytes = 2 * Int(System.pageSize)
        #expect(size.rawValue == Int64(expectedBytes))
    }

    // MARK: - Constants

    @Test
    func `zero constant`() {
        #expect(Kernel.File.Size.zero == 0)
    }

    @Test
    func `kilobyte constant`() {
        #expect(Kernel.File.Size.kilobyte == 1024)
    }

    @Test
    func `megabyte constant`() {
        #expect(Kernel.File.Size.megabyte.rawValue == 1024 * 1024)
    }

    @Test
    func `gigabyte constant`() {
        #expect(Kernel.File.Size.gigabyte.rawValue == 1024 * 1024 * 1024)
    }

    @Test
    func `page constant`() {
        let pageSizeBytes = UInt(Int(System.pageSize))
        let pageSize = Kernel.File.Size.page(size: pageSizeBytes)
        #expect(pageSize.rawValue == Int64(pageSizeBytes))
    }

    // MARK: - Queries

    @Test
    func `isZero for zero size`() {
        #expect(Kernel.File.Size.zero.isZero)
    }

    @Test
    func `isZero for non-zero size`() {
        let size: Kernel.File.Size = 100
        #expect(!size.isZero)
    }

    @Test
    func `isPositive for positive size`() {
        let size: Kernel.File.Size = 100
        #expect(size.isPositive)
    }

    @Test
    func `isPositive for zero`() {
        #expect(!Kernel.File.Size.zero.isPositive)
    }

    // MARK: - Arithmetic

    @Test
    func `Size plus Size`() {
        let a: Kernel.File.Size = 1000
        let b: Kernel.File.Size = 2000
        let result = a + b
        #expect(result == 3000)
    }

    @Test
    func `Size minus Size`() {
        let a: Kernel.File.Size = 3000
        let b: Kernel.File.Size = 1000
        let result = a - b
        #expect(result == 2000)
    }

    // MARK: - Int Conversion

    @Test
    func `Int from Size`() {
        let size: Kernel.File.Size = 4096
        let intValue = Int(size)
        #expect(intValue == 4096)
    }

    // MARK: - Conformances

    @Test
    func `Size is Equatable`() {
        let a: Kernel.File.Size = 4096
        let b: Kernel.File.Size = 4096
        let c: Kernel.File.Size = 8192
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Size is Hashable`() {
        var set = Set<Kernel.File.Size>()
        set.insert(Kernel.File.Size(1024))
        set.insert(Kernel.File.Size(2048))
        set.insert(Kernel.File.Size(1024))  // duplicate
        #expect(set.count == 2)
    }

    @Test
    func `Size is Sendable`() {
        let size: any Sendable = Kernel.File.Size(4096)
        #expect(size is Kernel.File.Size)
    }

    @Test
    func `Size is Comparable`() {
        let a: Kernel.File.Size = 1024
        let b: Kernel.File.Size = 2048
        #expect(a < b)
        #expect(b > a)
    }
}
