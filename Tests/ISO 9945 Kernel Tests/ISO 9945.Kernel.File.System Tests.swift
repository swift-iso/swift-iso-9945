import ISO_9945_Kernel
import Tagged_Primitives_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.File.System {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.File.System.Test.Unit {
    @Test
    func `System namespace exists`() {
        _ = ISO_9945.Kernel.File.System.self
    }

    @Test
    func `System is an enum`() {
        let _: ISO_9945.Kernel.File.System.Type = ISO_9945.Kernel.File.System.self
    }
}

extension ISO_9945.Kernel.File.System.Test.Unit {
    @Test
    func `System.Kind type exists`() {
        let _: ISO_9945.Kernel.File.System.Kind.Type = ISO_9945.Kernel.File.System.Kind.self
    }

    @Test
    func `System.Stats type exists`() {
        let _: ISO_9945.Kernel.File.System.Stats.Type = ISO_9945.Kernel.File.System.Stats.self
    }

    @Test
    func `System.Block type exists`() {
        let _: ISO_9945.Kernel.File.System.Block.Type = ISO_9945.Kernel.File.System.Block.self
    }
}
