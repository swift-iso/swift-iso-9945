import ISO_9945_Kernel
import Tagged
import Testing

extension ISO_9945.Kernel.Copy {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension ISO_9945.Kernel.Copy.Test.Unit {

    #if os(Linux) || canImport(Darwin)

    #endif

    #if os(Linux)

    #endif
}
