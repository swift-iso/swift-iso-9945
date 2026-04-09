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

extension Kernel.System {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Path Max Unit Tests

extension Kernel.System.Test.Unit {
    @Test("pathMax is positive")
    func pathMaxPositive() {
        #expect(Kernel.System.pathMax > 0)
    }

    @Test("pathMax is reasonable")
    func pathMaxReasonable() {
        // PATH_MAX should be at least 256 on any platform
        #expect(Kernel.System.pathMax >= 256)
        // And not unreasonably large (sanity check)
        #expect(Kernel.System.pathMax <= 65536)
    }

    #if os(macOS)
        @Test("macOS pathMax is 1024")
        func macOSPathMax() {
            #expect(Kernel.System.pathMax == 1024)
        }
    #endif

    #if os(Linux)
        @Test("Linux pathMax is typically 4096")
        func linuxPathMax() {
            #expect(Kernel.System.pathMax == 4096)
        }
    #endif
}

// MARK: - Page Size Unit Tests

extension Kernel.System.Test.Unit {
    @Test("pageSize is positive")
    func pageSizePositive() {
        #expect(Kernel.System.pageSize > 0)
    }

    @Test("pageSize is power of 2")
    func pageSizePowerOfTwo() {
        let size = Int(Kernel.System.pageSize)
        // A power of 2 has exactly one bit set
        #expect(size & (size - 1) == 0)
    }

    @Test("pageSize is at least 4KB")
    func pageSizeMinimum() {
        // Most systems have at least 4KB pages
        #expect(Kernel.System.pageSize >= 4096)
    }

    #if os(macOS) && arch(arm64)
        @Test("pageSize is 16KB on Apple Silicon")
        func pageSizeAppleSilicon() {
            #expect(Kernel.System.pageSize == 16384)
        }
    #endif
}

// MARK: - Allocation Granularity Unit Tests

extension Kernel.System.Test.Unit {
    @Test("allocationGranularity is positive")
    func allocationGranularityPositive() {
        let granularity = Kernel.Memory.Allocation.system
        let size: Int = granularity.rawValue.magnitude()
        #expect(size > 0)
    }

    @Test("allocationGranularity is power of 2")
    func allocationGranularityPowerOfTwo() {
        let granularity = Kernel.Memory.Allocation.system
        // Memory.Alignment always represents a power of 2
        let size: Int = granularity.rawValue.magnitude()
        #expect(size & (size - 1) == 0)
    }

        @Test("allocationGranularity equals pageSize on POSIX")
        func allocationGranularityEqualsPageSize() {
            let granularity = Kernel.Memory.Allocation.system
            // Compare underlying values since these are different types
            let size: Int = granularity.rawValue.magnitude()
            #expect(size == Int(Kernel.System.pageSize))
        }
}

// MARK: - Consistency Tests

extension Kernel.System.Test.Unit {
    @Test("pageSize is consistent across calls")
    func pageSizeConsistent() {
        let size1 = Kernel.System.pageSize
        let size2 = Kernel.System.pageSize
        let size3 = Kernel.System.pageSize

        #expect(size1 == size2)
        #expect(size2 == size3)
    }

    @Test("allocationGranularity is consistent across calls")
    func allocationGranularityConsistent() {
        let granularity1 = Kernel.Memory.Allocation.system
        let granularity2 = Kernel.Memory.Allocation.system

        #expect(granularity1 == granularity2)
    }
}
