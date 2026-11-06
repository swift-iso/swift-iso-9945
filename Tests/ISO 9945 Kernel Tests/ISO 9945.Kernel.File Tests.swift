import ISO_9945_Kernel
import Tagged
import Testing

enum `ISO_9945.Kernel.File Tests` {}

extension `ISO_9945.Kernel.File Tests` {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}
