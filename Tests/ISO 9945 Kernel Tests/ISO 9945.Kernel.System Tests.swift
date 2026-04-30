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

extension System {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Path Max Unit Tests

extension System.Test.Unit {
    @Test
    func `pathMax is positive`() {
        #expect(System.pathMax > 0)
    }

    @Test
    func `pathMax is reasonable`() {
        // PATH_MAX should be at least 256 on any platform
        #expect(System.pathMax >= 256)
        // And not unreasonably large (sanity check)
        #expect(System.pathMax <= 65536)
    }

    #if os(macOS)
        @Test
        func `macOS pathMax is 1024`() {
            #expect(System.pathMax == 1024)
        }
    #endif

    #if os(Linux)
        @Test
        func `Linux pathMax is typically 4096`() {
            #expect(System.pathMax == 4096)
        }
    #endif
}

// MARK: - Page Size Unit Tests

extension System.Test.Unit {
    @Test
    func `pageSize is positive`() {
        #expect(System.pageSize > 0)
    }

    @Test
    func `pageSize is power of 2`() {
        let size = Int(System.pageSize)
        // A power of 2 has exactly one bit set
        #expect(size & (size - 1) == 0)
    }

    @Test
    func `pageSize is at least 4KB`() {
        // Most systems have at least 4KB pages
        #expect(System.pageSize >= 4096)
    }

    #if os(macOS) && arch(arm64)
        @Test
        func `pageSize is 16KB on Apple Silicon`() {
            #expect(System.pageSize == 16384)
        }
    #endif
}

// MARK: - Allocation Granularity Unit Tests

extension System.Test.Unit {
    @Test
    func `allocationGranularity is positive`() {
        let granularity = Memory.Allocation.system
        let size: Int = granularity.rawValue.magnitude()
        #expect(size > 0)
    }

    @Test
    func `allocationGranularity is power of 2`() {
        let granularity = Memory.Allocation.system
        // Memory.Alignment always represents a power of 2
        let size: Int = granularity.rawValue.magnitude()
        #expect(size & (size - 1) == 0)
    }

        @Test
        func `allocationGranularity equals pageSize on POSIX`() {
            let granularity = Memory.Allocation.system
            // Compare underlying values since these are different types
            let size: Int = granularity.rawValue.magnitude()
            #expect(size == Int(System.pageSize))
        }
}

// MARK: - Consistency Tests

extension System.Test.Unit {
    @Test
    func `pageSize is consistent across calls`() {
        let size1 = System.pageSize
        let size2 = System.pageSize
        let size3 = System.pageSize

        #expect(size1 == size2)
        #expect(size2 == size3)
    }

    @Test
    func `allocationGranularity is consistent across calls`() {
        let granularity1 = Memory.Allocation.system
        let granularity2 = Memory.Allocation.system

        #expect(granularity1 == granularity2)
    }
}
