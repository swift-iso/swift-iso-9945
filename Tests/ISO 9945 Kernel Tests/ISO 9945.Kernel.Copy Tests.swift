import ISO_9945_Kernel
import Tagged_Primitives_Standard_Library_Integration
import Testing

extension ISO_9945.Kernel.Copy {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

extension ISO_9945.Kernel.Copy.Test.Unit {
    @Test
    func `Copy namespace exists`() {

        _ = ISO_9945.Kernel.Copy.self
    }

    @Test
    func `Copy is an enum`() {
        let _: ISO_9945.Kernel.Copy.Type = ISO_9945.Kernel.Copy.self
    }

    @Test
    func `Copy is Sendable`() {
        let _: any Sendable.Type = ISO_9945.Kernel.Copy.self
    }
}

extension ISO_9945.Kernel.Copy.Test.Unit {
    @Test
    func `Copy.Error type exists`() {
        let _: ISO_9945.Kernel.Copy.Error.Type = ISO_9945.Kernel.Copy.Error.self
    }

    #if os(Linux) || canImport(Darwin)
        @Test
        func `Copy.Clone namespace exists`() {
            let _: ISO_9945.Kernel.Copy.Clone.Type = ISO_9945.Kernel.Copy.Clone.self
        }
    #endif

    #if os(Linux)
        @Test
        func `Copy.Range namespace exists on Linux`() {
            let _: ISO_9945.Kernel.Copy.Range.Type = ISO_9945.Kernel.Copy.Range.self
        }
    #endif
}
