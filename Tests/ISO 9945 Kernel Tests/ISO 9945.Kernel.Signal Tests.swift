import Error
import Path
import Tagged
import Testing

@testable import ISO_9945_Kernel

enum `ISO_9945.Kernel.Signal Tests` {}

extension `ISO_9945.Kernel.Signal Tests` {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
        @Suite struct Integration {}
    }
}

extension `ISO_9945.Kernel.Signal Tests`.Test.Unit {
    #if canImport(Darwin) || canImport(Glibc) || canImport(Musl)

    #endif
}
