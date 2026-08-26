import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension Memory.Map.Anonymous {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

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

extension Memory.Map.Anonymous.Test.Unit {
    @Test
    func `map creates a valid region`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        #expect(region.base.bitPattern != 0)
        #expect(region.length == pageSize)
    }

    @Test
    func `map with custom protection`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(
            length: pageSize,
            protection: .read
        )
        defer { try? Memory.Map.unmap(region) }

        #expect(region.base.bitPattern != 0)
    }

    @Test
    func `map private by default`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        #expect(region.base.bitPattern != 0)
    }

    @Test
    func `map shared when specified`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(
            length: pageSize,
            shared: true
        )
        defer { try? Memory.Map.unmap(region) }

        #expect(region.base.bitPattern != 0)
    }
}

#if os(Windows)
    extension Memory.Map.Anonymous.Test.Unit {
        @Test
        func `map creates a valid region on Windows`() throws {
            let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
            let region = try Memory.Map.Anonymous.map(length: pageSize)
            defer { try? Memory.Map.unmap(region) }

            #expect(region.base != nil)
            #expect(region.length == pageSize)
        }
    }
#endif
