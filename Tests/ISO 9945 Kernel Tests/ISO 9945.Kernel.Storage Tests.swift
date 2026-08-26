import ISO_9945_Kernel
import Tagged_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.Storage {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.Storage.Test.Unit {
    @Test
    func `Storage namespace exists`() {
        _ = ISO_9945.Kernel.Storage.self
    }

    @Test
    func `Storage is an enum`() {
        let _: ISO_9945.Kernel.Storage.Type = ISO_9945.Kernel.Storage.self
    }
}

extension ISO_9945.Kernel.Storage.Test.Unit {
    @Test
    func `Storage.Error type exists`() {
        let _: ISO_9945.Kernel.Storage.Error.Type = ISO_9945.Kernel.Storage.Error.self
    }
}
