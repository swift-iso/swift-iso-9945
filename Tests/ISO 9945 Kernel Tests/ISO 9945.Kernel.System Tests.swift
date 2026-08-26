import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension System {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension System.Test.Unit {
    @Test
    func `pathMax is positive`() {
        #expect(System.pathMax > 0)
    }

    @Test
    func `pathMax is reasonable`() {

        #expect(System.pathMax >= 256)

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

extension System.Test.Unit {
    @Test
    func `pageSize is positive`() {
        #expect(System.pageSize > 0)
    }

    @Test
    func `pageSize is power of 2`() {
        let size = Int(System.pageSize)

        #expect(size & (size - 1) == 0)
    }

    @Test
    func `pageSize is at least 4KB`() {

        #expect(System.pageSize >= 4096)
    }

    #if os(macOS) && arch(arm64)
        @Test
        func `pageSize is 16KB on Apple Silicon`() {
            #expect(System.pageSize == 16384)
        }
    #endif
}

extension System.Test.Unit {
    @Test
    func `allocationGranularity is positive`() {
        let granularity = Memory.Allocation.system
        let size: Int = granularity.underlying.magnitude()
        #expect(size > 0)
    }

    @Test
    func `allocationGranularity is power of 2`() {
        let granularity = Memory.Allocation.system

        let size: Int = granularity.underlying.magnitude()
        #expect(size & (size - 1) == 0)
    }

    @Test
    func `allocationGranularity equals pageSize on POSIX`() {
        let granularity = Memory.Allocation.system

        let size: Int = granularity.underlying.magnitude()
        #expect(size == Int(System.pageSize))
    }
}

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
