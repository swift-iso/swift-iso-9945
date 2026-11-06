import Error
import ISO_9945_Kernel_Test_Support
import Path
import Tagged
import Testing

@testable import ISO_9945_Kernel

enum `ISO_9945.Kernel.Thread.Handle Tests` {}

extension `ISO_9945.Kernel.Thread.Handle Tests` {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension `ISO_9945.Kernel.Thread.Handle Tests`.Test.Unit {
}
