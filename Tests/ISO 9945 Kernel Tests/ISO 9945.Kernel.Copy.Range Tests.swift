#if os(Linux)

    import Testing
    import Tagged
    import ISO_9945_Kernel

    extension ISO_9945.Kernel.Copy.Range {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
        }
    }

    extension ISO_9945.Kernel.Copy.Range.Test.Unit {

    }

#endif
