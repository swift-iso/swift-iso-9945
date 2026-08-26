import ISO_9945_Kernel
import Tagged_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.IO.Blocking {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.IO.Blocking.Test.Unit {
    @Test
    func `Blocking namespace exists`() {

        _ = ISO_9945.Kernel.IO.Blocking.self
    }

    @Test
    func `Blocking is an enum`() {
        let _: ISO_9945.Kernel.IO.Blocking.Type = ISO_9945.Kernel.IO.Blocking.self
    }

    @Test
    func `Blocking is Sendable`() {
        let _: any Sendable.Type = ISO_9945.Kernel.IO.Blocking.self
    }
}

extension ISO_9945.Kernel.IO.Blocking.Test.Unit {
    @Test
    func `Blocking.Error type exists`() {
        let _: ISO_9945.Kernel.IO.Blocking.Error.Type = ISO_9945.Kernel.IO.Blocking.Error.self
    }
}
