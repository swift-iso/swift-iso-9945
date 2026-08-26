#if os(Linux)

    import Testing
    import Tagged_Standard_Library_Integration
    import ISO_9945_Kernel

    extension ISO_9945.Kernel.Copy.Range {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
        }
    }

    extension ISO_9945.Kernel.Copy.Range.Test.Unit {
        @Test
        func `Range namespace exists`() {

            _ = ISO_9945.Kernel.Copy.Range.self
        }

        @Test
        func `Range is an enum`() {
            let _: ISO_9945.Kernel.Copy.Range.Type = ISO_9945.Kernel.Copy.Range.self
        }

    }

#endif
