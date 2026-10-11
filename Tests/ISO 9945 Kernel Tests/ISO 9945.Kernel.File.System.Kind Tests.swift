import ISO_9945_Kernel
import Tagged
import Testing

extension ISO_9945.Kernel.File.System.Kind {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension ISO_9945.Kernel.File.System.Kind.Test.Unit {
    @Test
    func `Kind from rawValue`() {
        let kind = ISO_9945.Kernel.File.System.Kind(rawValue: 0x1234)
        #expect(kind.rawValue == 0x1234)
    }

    @Test
    func `Kind from UInt64`() {
        let kind = ISO_9945.Kernel.File.System.Kind(0xABCD)
        #expect(kind.rawValue == 0xABCD)
    }

    @Test
    func `rawValue roundtrip`() {
        let original: UInt64 = 0x9123_683E
        let kind = ISO_9945.Kernel.File.System.Kind(rawValue: original)
        #expect(kind.rawValue == original)
    }
}

extension ISO_9945.Kernel.File.System.Kind.Test.Unit {
    @Test
    func `Kind is Sendable`() {
        let kind: any Sendable = ISO_9945.Kernel.File.System.Kind(0x1234)
        #expect(kind is ISO_9945.Kernel.File.System.Kind)
    }

    @Test
    func `Kind is Equatable`() {
        let a = ISO_9945.Kernel.File.System.Kind(0x1234)
        let b = ISO_9945.Kernel.File.System.Kind(0x1234)
        let c = ISO_9945.Kernel.File.System.Kind(0x5678)
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Kind is Hashable`() {
        var set = Set<ISO_9945.Kernel.File.System.Kind>()
        set.insert(ISO_9945.Kernel.File.System.Kind(0x1234))
        set.insert(ISO_9945.Kernel.File.System.Kind(0x5678))
        set.insert(ISO_9945.Kernel.File.System.Kind(0x1234))
        #expect(set.count == 2)
    }

    @Test
    func `Kind is RawRepresentable`() {
        let kind = ISO_9945.Kernel.File.System.Kind(rawValue: 0x1234)
        let fromRaw = ISO_9945.Kernel.File.System.Kind(rawValue: kind.rawValue)
        #expect(kind == fromRaw)
    }

    @Test
    func `Kind is CustomStringConvertible`() {
        let kind: any CustomStringConvertible = ISO_9945.Kernel.File.System.Kind(0x1234)
        #expect(!kind.description.isEmpty)
    }
}
