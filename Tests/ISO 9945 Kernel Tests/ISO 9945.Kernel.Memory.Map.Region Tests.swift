import Error_Primitives
import ISO_9945_Kernel_Test_Support
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension Memory.Map.Region {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension Memory.Map.Region.Test.Unit {
    @Test
    func `Region type exists`() {
        let _: Memory.Map.Region.Type = Memory.Map.Region.self
    }

    @Test
    func `Region is @unchecked Sendable`() {

        let _: any Sendable.Type = Memory.Map.Region.self
    }
}

extension Memory.Map.Region.Test.Unit {
    @Test
    func `Region stores base address`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        #expect(region.base.bitPattern != 0)
    }

    @Test
    func `Region stores length`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        #expect(region.length == pageSize)
    }

    @Test
    func `Region init sets values correctly`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        let copy = Memory.Map.Region(base: region.base, length: region.length)
        #expect(copy.base == region.base)
        #expect(copy.length == region.length)
    }
}

#if os(Windows)
    extension Memory.Map.Region.Test.Unit {
        @Test
        func `Region stores mappingHandle on Windows`() throws {
            let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
            let region = try Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Memory.Map.unmap(region) }

            #expect(region.mappingHandle != nil)
        }
    }
#endif
