import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged
import Testing

@testable import ISO_9945_Kernel

enum `Memory.Map.Anonymous Tests` {}

extension `Memory.Map.Anonymous Tests` {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension `Memory.Map.Anonymous Tests`.Test.Unit {
    @Test
    func `map creates a valid region`() throws {
        let pageSize = Memory.Address.Count(Memory.Page.size.underlying.rawValue)
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        #expect(region.base.bitPattern != 0)
        #expect(region.length == pageSize)
    }

    @Test
    func `map with custom protection`() throws {
        let pageSize = Memory.Address.Count(Memory.Page.size.underlying.rawValue)
        let region = try Memory.Map.Anonymous.map(
            length: pageSize,
            protection: .read
        )
        defer { try? Memory.Map.unmap(region) }

        #expect(region.base.bitPattern != 0)
    }

    @Test
    func `map private by default`() throws {
        let pageSize = Memory.Address.Count(Memory.Page.size.underlying.rawValue)
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        #expect(region.base.bitPattern != 0)
    }

    @Test
    func `map shared when specified`() throws {
        let pageSize = Memory.Address.Count(Memory.Page.size.underlying.rawValue)
        let region = try Memory.Map.Anonymous.map(
            length: pageSize,
            shared: true
        )
        defer { try? Memory.Map.unmap(region) }

        #expect(region.base.bitPattern != 0)
    }
}
