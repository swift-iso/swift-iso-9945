import ISO_9945_Kernel
import Tagged_Primitives_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.File {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.File.Test.Unit {
    @Test
    func `File namespace exists`() {

        _ = ISO_9945.Kernel.File.self
    }
}
