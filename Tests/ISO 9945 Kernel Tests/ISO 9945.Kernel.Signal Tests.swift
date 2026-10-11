import Error
import Path
import Tagged
import Testing

@testable import ISO_9945_Kernel

extension ISO_9945.Kernel.Signal {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension ISO_9945.Kernel.Signal.Test.Unit {
}

extension ISO_9945.Kernel.Signal.Test.Unit {
    #if canImport(Darwin) || canImport(Glibc) || canImport(Musl)

    #endif
}
