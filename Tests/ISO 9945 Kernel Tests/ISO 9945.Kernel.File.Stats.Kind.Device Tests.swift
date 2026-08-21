import ISO_9945_Kernel
import Tagged_Primitives_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.File.Stats.Kind.Device {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.File.Stats.Kind.Device.Test.Unit {
    @Test
    func `block case exists`() {
        let device = ISO_9945.Kernel.File.Stats.Kind.Device.block
        if case .block = device {

        } else {
            Issue.record("Expected .block case")
        }
    }

    @Test
    func `character case exists`() {
        let device = ISO_9945.Kernel.File.Stats.Kind.Device.character
        if case .character = device {

        } else {
            Issue.record("Expected .character case")
        }
    }
}

extension ISO_9945.Kernel.File.Stats.Kind.Device.Test.Unit {
    @Test
    func `Device is Sendable`() {
        let device: any Sendable = ISO_9945.Kernel.File.Stats.Kind.Device.block
        #expect(device is ISO_9945.Kernel.File.Stats.Kind.Device)
    }

    @Test
    func `Device is Equatable`() {
        let a = ISO_9945.Kernel.File.Stats.Kind.Device.block
        let b = ISO_9945.Kernel.File.Stats.Kind.Device.block
        let c = ISO_9945.Kernel.File.Stats.Kind.Device.character
        #expect(a == b)
        #expect(a != c)
    }

    @Test
    func `Device is Hashable`() {
        var set = Set<ISO_9945.Kernel.File.Stats.Kind.Device>()
        set.insert(.block)
        set.insert(.character)
        set.insert(.block)
        #expect(set.count == 2)
    }
}

extension ISO_9945.Kernel.File.Stats.Kind.Device.Test.EdgeCase {
    @Test
    func `block and character are distinct`() {
        let block = ISO_9945.Kernel.File.Stats.Kind.Device.block
        let character = ISO_9945.Kernel.File.Stats.Kind.Device.character
        #expect(block != character)
    }
}
