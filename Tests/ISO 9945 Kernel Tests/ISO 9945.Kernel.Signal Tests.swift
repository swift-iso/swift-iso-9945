import Error_Primitives
import Path_Primitives
import Tagged_Primitives_Standard_Library_Integration
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Signal {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
        @Suite struct Integration {}
        @Suite(.serialized) struct Performance {}
    }
}

extension ISO_9945.Kernel.Signal.Test.Unit {
    @Test
    func `Signal namespace exists`() {
        _ = ISO_9945.Kernel.Signal.self
    }

    @Test
    func `Signal is an enum`() {
        let _: ISO_9945.Kernel.Signal.Type = ISO_9945.Kernel.Signal.self
    }
}

extension ISO_9945.Kernel.Signal.Test.Unit {
    #if canImport(Darwin) || canImport(Glibc) || canImport(Musl)
        @Test
        func `Signal.Error type exists`() {
            let _: ISO_9945.Kernel.Signal.Error.Type = ISO_9945.Kernel.Signal.Error.self
        }
    #endif
}
