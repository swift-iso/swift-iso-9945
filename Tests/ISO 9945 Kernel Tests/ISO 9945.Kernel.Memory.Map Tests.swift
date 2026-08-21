import Error_Primitives
import ISO_9945_Kernel_Test_Support
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension Memory.Map {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension Memory.Map.Test.Unit {
    @Test
    func `anonymous map succeeds`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        #expect(region.base.bitPattern != 0)
        #expect(region.length == pageSize)
    }

    @Test
    func `map and unmap cycle works`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)

        try Memory.Map.unmap(region)

    }

    @Test
    func `mapped memory is readable and writable`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(
            length: pageSize,
            protection: .readWrite
        )
        defer { try? Memory.Map.unmap(region) }

        unsafe region.base.mutablePointer.storeBytes(of: UInt8(42), toByteOffset: 0, as: UInt8.self)
        unsafe region.base.mutablePointer.storeBytes(
            of: UInt8(123),
            toByteOffset: 1,
            as: UInt8.self
        )

        #expect(unsafe region.base.pointer.load(fromByteOffset: 0, as: UInt8.self) == 42)
        #expect(unsafe region.base.pointer.load(fromByteOffset: 1, as: UInt8.self) == 123)
    }

    @Test
    func `sync succeeds on mapped region`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        try Memory.Map.sync(addr: region.base, length: region.length)
    }

    @Test
    func `protect changes memory protection`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(
            length: pageSize,
            protection: .readWrite
        )
        defer { try? Memory.Map.unmap(region) }

        unsafe region.base.mutablePointer.storeBytes(of: UInt8(99), toByteOffset: 0, as: UInt8.self)

        try Memory.Map.protect(
            addr: region.base,
            length: region.length,
            protection: .read
        )

        #expect(unsafe region.base.pointer.load(fromByteOffset: 0, as: UInt8.self) == 99)

    }

    @Test
    func `advise does not throw`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        Memory.Map.advise(
            addr: region.base,
            length: region.length,
            advice: .normal
        )
    }

    @Test
    func `multi-page mapping works`() throws {
        let multiPageSize = Memory.Address.Count(4 * UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: multiPageSize)
        defer { try? Memory.Map.unmap(region) }

        #expect(region.length == multiPageSize)

        let lastOffset = try Int(region.length.subtract.saturating(.one))
        unsafe region.base.mutablePointer.storeBytes(of: UInt8(1), toByteOffset: 0, as: UInt8.self)
        unsafe region.base.mutablePointer.storeBytes(
            of: UInt8(255),
            toByteOffset: lastOffset,
            as: UInt8.self
        )

        #expect(unsafe region.base.pointer.load(fromByteOffset: 0, as: UInt8.self) == 1)
        #expect(unsafe region.base.pointer.load(fromByteOffset: lastOffset, as: UInt8.self) == 255)
    }

    @Test
    func `Region struct stores base and length`() throws {
        let pageSize = Memory.Address.Count(UInt(Int(System.pageSize)))
        let region = try Memory.Map.Anonymous.map(length: pageSize)
        defer { try? Memory.Map.unmap(region) }

        #expect(region.base.bitPattern != 0)
        #expect(region.length == pageSize)
    }
}

extension Memory.Map.Test.EdgeCase {
    @Test
    func `map with zero length throws`() {
        #expect(throws: Memory.Map.Error.self) {
            _ = try Memory.Map.Anonymous.map(length: .zero)
        }
    }

    @Test
    func `map with zero length throws invalid length error`() {
        do {
            _ = try Memory.Map.Anonymous.map(length: .zero)
            Issue.record("Expected error to be thrown")
        } catch {
            if case .invalid(.length) = error {

            } else {
                Issue.record("Expected .invalid(.length), got \(error)")
            }
        }
    }
}
